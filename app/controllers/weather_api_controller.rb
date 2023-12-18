class WeatherApiController < ApplicationController
  def index
    @newcastle_weather = ForecastService.new().call(54.971250, -1.614590)
    @vancouver_weather = ForecastService.new().call(49.286610, -123.118550)
    @st_julians_weather = ForecastService.new().call(35.916160, 14.491080)
  end
end
