require "faraday"
require "json"

class OpenWeatherMapService
  def initialize
    @api_key = Rails.application.credentials.open_weather_map[:api_key]
    @conn = Faraday.new(
      url: "https://api.openweathermap.org/data/2.5/",
      params: { appid: @api_key, units: "metric" }
    )
  end

  def current_weather_for(office_latitude, office_longitude)
    fetch_data_for("weather", {lat: office_latitude, lon: office_longitude, appid: @api_key})
  end

  def forecast_for(office_latitude, office_longitude)
    fetch_data_for("forecast", {lat: office_latitude, lon: office_longitude, appid: @api_key})
  end

  private

  def fetch_data_for(resource_path, params)
    res = @conn.get(resource_path, params)

    if res.success?
      {data: JSON.parse(res.body), code: res.status, err: nil, url: res.env.url }
    else
      {data: nil, code: res.status, err: res.reason_phrase, url: res.env.url }
    end
  end
end
