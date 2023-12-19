class Weather < ApplicationRecord
  belongs_to :office, query_constraints: [:lat, :lon, :dt]

  def self.update_weather_data(lat, lon, dt)
    forecast_data = ForecastService.new.call(lat, lon, dt)

    if forecast_data
      upsert_all(forecast_data)
    end
  end

  def self.current_weather(lat, lon)
    dt = normalised_req_time
    update_weather_data(lat, lon, dt)

    find_by(lat: lat, lon: lon, dt: dt)
  end

  def self.forecast(lat, lon)
    update_weather_data(lat, lon, normalised_req_time)

    forecast_start = Time.now.utc.beginning_of_day
    forecast_end = forecast_start.advance(days: 4)

    where(lat: lat, lon: lon, dt: forecast_start...forecast_end).order(:dt)
  end

  # The data structure constructed by the service object is a list of weather
  # objects. These are for intervals of time at a specific location. Because the
  # request time is not going to be at one of those times, need to shift it
  # *down* to the last interval.
  def self.normalised_req_time
    # The forecast by default provides 8 daily records: 00:00, 03:00, 06:00,
    # 09:00, 12:00, 15:00, 18:00, and 21:00. Grab the closest one to the current time
    req_per_day = 8
    cache_interval = 24 / 8

    (0...req_per_day)
      .map { |i| DateTime.parse("00:00") + Rational(cache_interval * i, 24) }
      .min_by { |time| (DateTime.now.utc - time).abs }
  end
end
