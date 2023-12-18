class Weather < ApplicationRecord
    belongs_to :office, query_constraints: [:lat, :lon, :dt]
end
