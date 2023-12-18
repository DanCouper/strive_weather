require "faraday"
require "json"

class OpenWeatherMapService
  def initialize
    @api_key = Rails.application.credentials.open_weather_map[:api_key]
    @conn = Faraday.new(
      url: "https://api.openweathermap.org/data/2.5/",
      params: {appid: @api_key, units: "metric"}
    )
  end

  def current_weather_for(office_latitude, office_longitude)
    fetch_data_for("weather", {lat: office_latitude, lon: office_longitude, appid: @api_key})
  end

  def forecast_for(office_latitude, office_longitude)
    fetch_data_for("forecast", {lat: office_latitude, lon: office_longitude, appid: @api_key})
  end

  # The structure I want to parse a *single*  
  #     t.string(:dt)
  #     t.float(:lat)
  #     t.float(:lon)
  #     t.string(:name)
  #     t.string(:desc)
  #     t.float(:average_temp)
  #     t.float(:max_temp)
  #     t.string(:min_temp)
  #     t.string(:float)
  #     t.float(:feels_like)
  #     t.integer(:humidity)
  #     t.integer(:cloud_cover)
  #     t.float(:wind_speed)
  #     t.integer(:wind_direction)
  #     t.float(:wind_gust)


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
  def parse_forecast_resp(json_resp)
    resp = JSON.parse(json_resp, { symbolize_names: true })

    resp.list.map { | forecast_entry | OpenWeatherMapService::parse_single_forecast_entry(forecast_entry, resp.city.coord.lat, resp.city.coord.lon ) }
    
  end

  def parse_single_forecast_entry(entry, lat, lon)
    {
      dt:             entry.dt,
      lat:            lat,
      lon:            lon,
      name:           entry.weather[0].main,
      desc:           entry.weather[0].description,
      average_temp:   entry.main.temp,
      max_temp:       entry.main.temp_min,
      min_temp:       entry.main.temp_min,
      feels_like:     entry.main.feels_like,
      humidity:       entry.main.humidity,
      cloud_cover:    entry.clouds.all,
      wind_speed:     entry.wind.speed,
      wind_direction: entry.wind.deg,
      wind_gust:      entry.wind.gust,
    }
  end

  private

  def fetch_data_for(resource_path, params)
    res = @conn.get(resource_path, params)

    if res.success?
      {data: JSON.parse(res.body), code: res.status, err: nil, url: res.env.url}
    else
      {data: nil, code: res.status, err: res.reason_phrase, url: res.env.url}
    end
  end
end
