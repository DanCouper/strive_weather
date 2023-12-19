module OfficesHelper
  # A four-day forecast is provided, with [max*] 8 entries per day.
  # The data is in a flat array, ordered by date, starting with today.
  # However, the data may only exist from the current time onwards.
  def chunked_forecast_data(forecast_list)
    first_entry_dt = DateTime.parse(forecast_list[0][:dt])

    # (0...4).map
  end
end
