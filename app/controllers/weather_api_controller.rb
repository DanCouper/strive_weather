class WeatherApiController < ApplicationController
  def index
    api = OpenWeatherMapService.new()

    @newcastle_weather  = api.current_weather_for(54.971250, -1.614590)
    @vancouver_weather  = api.current_weather_for(49.286610, -123.118550)
    @st_julians_weather = api.current_weather_for(35.916160, 14.491080)
  end
end
