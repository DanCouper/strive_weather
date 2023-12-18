class Office < ApplicationRecord
  # NOTE: Weather is already indexed using a composite key of [lat, lon, dt], don't think
  # indexing & foreign key provide much benefit here, but needs investigation
  has_many :weathers, primary_key: [:lat, :lon, :dt], query_constraints: [:lat, :lon, :dt]

  def current_weather
    target_time = forecast_service.normalised_req_time
    weathers.find_by(lat: lat, lon: lon, dt: target_time)
  end

  def forecast
    forecast_start = Time.now.utc.beginning_of_day
    forecast_end = forecast_start.advance(days: 4)
    weathers.where([lat, lon, forecast_start...forecast_end])
  end

  def update_weather_data
    forecast_service.call(lat, lon)
  end

  private

  def forecast_service
    @forecast_service ||= ForecastService.new
  end
end
