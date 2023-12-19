require "faraday"
require "json"

# Make a request to the Open Weather Map API for a given location
# (specified by longitude and latitude).
#
# Makes two discrete requests, getting the current weather ("weather") endpoint
# and the forecast ("forecast") endpoint.
#
# Returns a data structure containing the current weather data + the forecast data.
#
# NOTE: this would be split into two service objects (current + forecast), but
# the amount of data is tiny. So for simplicity just return everything.
#
# The API responds with JSON on success. Should the request succeed, parse the
# JSON to the same structure as the model. The JSON parsing could occur at the
# call site, but if I'd had time to write some tests it's easier to test if
# I have the service object just return the exact same shape as I'm going to
# then use.
#
# NOTE: weather table data stucture:
#
#     t.string(:dt)
#     t.float(:lat)
#     t.float(:lon)
#     t.string(:name)
#     t.string(:desc)
#     t.float(:average_temp)
#     t.float(:max_temp)
#     t.string(:min_temp)
#     t.float(:feels_like)
#     t.integer(:humidity)
#     t.integer(:pressure)
#     t.integer(:cloud_cover)
#     t.float(:wind_speed)
#     t.integer(:wind_direction)
#     t.float(:wind_gust)
#
# NOTE: current weather data response shape:
#
# {
#   "coord": {
#     "lon": -1.6146,
#     "lat": 54.9713
#   },
#   "weather": [
#     {
#       "id": 803,
#       "main": "Clouds",
#       "description": "broken clouds",
#       "icon": "04n"
#     }
#   ],
#   "base": "stations",
#   "main": {
#     "temp": 8.43,
#     "feels_like": 6.57,
#     "temp_min": 8.16,
#     "temp_max": 9.21,
#     "pressure": 1029,
#     "humidity": 82
#   },
#   "visibility": 10000,
#   "wind": {
#     "speed": 3.09,
#     "deg": 230
#   },
#   "clouds": {
#     "all": 75
#   },
#   "dt": 1702663115,
#   "sys": {
#     "type": 1,
#     "id": 1427,
#     "country": "GB",
#     "sunrise": 1702628689,
#     "sunset": 1702654688
#   },
#   "timezone": 0,
#   "id": 2641673,
#   "name": "Newcastle upon Tyne",
#   "cod": 200
# }
#
# NOTE: forecast data response shape:
#
#  {
#     "cod": "200",
#     "message": 0,
#     "cnt": 40,
#     "list": [
#       {
#         "dt": 1702393200,
#         "main": {
#           "temp": 7.5,
#           "feels_like": 5.38,
#           "temp_min": 7.3,
#           "temp_max": 7.5,
#           "pressure": 995,
#           "sea_level": 995,
#           "grnd_level": 990,
#           "humidity": 98,
#           "temp_kf": 0.2
#         },
#         "weather": [
#           {
#             "id": 500,
#             "main": "Rain",
#             "description": "light rain",
#             "icon": "10d"
#           }
#         ],
#         "clouds": { "all": 83 },
#         "wind": { "speed": 3.2, "deg": 99, "gust": 6.8 },
#         "visibility": 4685,
#         "pop": 0.58,
#         "rain": { "3h": 0.39 },
#         "sys": { "pod": "d" },
#         "dt_txt": "2023-12-12 15:00:00"
#       },
#       .....
#     ],
#     "city": {
#       "id": 2641673,
#       "name": "Newcastle upon Tyne",
#       "coord": { "lat": 54.9713, "lon": -1.6146 },
#       "country": "GB",
#       "population": 192382,
#       "timezone": 0,
#       "sunrise": 1702369308,
#       "sunset": 1702395503
#     }
#  }
#
# FIXME: the API key needs to be redacted in the logs. The API key appears in
# the request parameters, *NOT* as a header. Faraday seems to allow this, via
# adding a filter block in the config like so:
#
# ```rb
# log_level: :debug do |filter|
#   filter.do_some_stuff_here
# end
# ```
class ForecastService
  def initialize
    # Set up the Faraday connection object for making external HTTP requests.
    @conn = Faraday.new(init_options) do |faraday|
      faraday.response(:logger, Rails.logger, log_level: :debug)
    end
  end

  def call(lat, lon, normalised_req_time)
    response = nil
    # The initial datetime of the data is the value is cached: if the datetime 
    # in the cache matches this initial datetime, can skip everything: the data
    # is already present.
    target_cache_key = "forecast/#{lat}/#{lon}"
    target_cache_value = normalised_req_time.to_s

    if Rails.cache.fetch(target_cache_key) == target_cache_value
      Rails.logger.info("Weather data update for latitude #{lat} longitude #{lon} skipped, data is already present in database.")
    else
      case fetch_combined_data(normalised_req_time, lat, lon)
        in { data: Array => data }
          response = data
          Rails.cache.write(target_cache_key, target_cache_value)
        in { err: String => err_msg}
          Rails.logger.debug("No cache key present, but the data update has failed: #{err_msg}")
      end
    end

    response
  end

  private

  # FIXME: I am just hardcoding the Faraday options for now rather than doing
  # anything fancy.
  def init_options
    {
      url: "https://api.openweathermap.org/data/2.5",
      params: {
        appid: Rails.application.credentials.open_weather_map[:api_key],
        units: "metric"
      },
      headers: {
        "Accept" => "application/json"
      }
    }
  end


  def fetch_combined_data(initial_dt, lat, lon)
    response = { data: nil, err: nil }

    case [fetch_data_for("weather", lat, lon), fetch_data_for("forecast", lat, lon)]
    in [{ data: Hash => curr_data}, {data: Hash => forecast_data}]
      initial_entry = [weather(initial_dt, lat, lon, curr_data)]
      rest_entries = forecast_data["list"].map { |data| weather(data["dt_txt"], lat, lon, data) }

      response[:data] =  initial_entry + rest_entries

    in [{ err: String => current_err_msg }, _]
      response[:err] = <<~EOS
        Failed to fetch current weather. #{current_err_msg}
        Request was made for weather at latitude #{lat}, longitude #{lon} and datetime #{initial_dt}"
      EOS

    in [_, { err: String => forecast_err_msg}]
      response[:err] = <<~EOS
        Failed to fetch forecast. #{forecast_err_msg}
        Request was made for weather at latitude #{lat}, longitude #{lon} and datetime #{initial_dt}"
      EOS

    end

    response
  end

  def fetch_data_for(endpoint, lat, lon)
    response = {data: nil, err: nil}

    begin
      raw_response = @conn.get(endpoint, {lat:, lon:})
      # Test for responses in the 400-500 range; these are not exceptions  
      if raw_response.success?
        response[:data] = JSON.parse(raw_response.body)
      else
        response[:err] = "HTTP request error #{raw_response.code}: #{raw_response.reason_phrase}"
      end

    rescue Faraday::Error => e
      response[:err] = "HTTP request failed: #{e.message}"

    rescue JSON::ParserError => e
      response[:err] = "JSON parsing failed: #{e.message}"

    # NOTE: anything else is currently unexpected, system should explode
    end

    response
  end

  # I'm sure this could be a lot better but, time
  def weather(dt, lat, lon, data)
    {
      dt: Time.parse(dt.to_s).utc,
      lat:,
      lon:,
      name: data["weather"][0]["main"],
      desc: data["weather"][0]["description"],
      average_temp: data["main"]["temp"],
      max_temp: data["main"]["temp_min"],
      min_temp: data["main"]["temp_max"],
      feels_like: data["main"]["feels_like"],
      humidity: data["main"]["humidity"],
      pressure: data["main"]["pressure"],
      cloud_cover: data["main"]["feels_like"],
      wind_speed: data["wind"]["speed"],
      wind_direction: data["wind"]["deg"],
      wind_gust: data["wind"]["gust"]
    }
  end
end
