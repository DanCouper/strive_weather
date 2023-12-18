class CreateWeathers < ActiveRecord::Migration[7.1]
  def change
    create_table(:weathers, primary_key: [:lat, :lon, :dt]) do |t|
      t.belongs_to(:office)
      t.datetime(:dt)
      t.float(:lat)
      t.float(:lon)
      t.string(:name)
      t.string(:desc)
      t.float(:average_temp)
      t.float(:max_temp)
      t.string(:min_temp)
      t.string(:float)
      t.float(:feels_like)
      t.integer(:humidity)
      t.integer(:pressure)
      t.integer(:cloud_cover)
      t.float(:wind_speed)
      t.integer(:wind_direction)
      t.float(:wind_gust)

      t.timestamps
    end
  end
end
