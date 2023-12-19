class Office < ApplicationRecord
  # NOTE: Weather is already indexed using a composite key of [lat, lon, dt], don't think
  # indexing & foreign key provide much benefit here, but needs investigation
  has_many :weathers, primary_key: [:lat, :lon, :dt], query_constraints: [:lat, :lon, :dt]

  def current_weather
    Weather.current_weather(lat, lon)
  end

  def forecast
    Weather.forecast(lat, lon)
  end
end
