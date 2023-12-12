# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
Office.destroy_all

Office.create!(
  [
    {
      municipality: "Newcastle",
      country: "UK",
      lat: 54.971250,
      lon: -1.614590
    },
    {
      municipality: "St Julian's",
      country: "Malta",
      lat: 35.916160,
      lon: 14.491080
    },
    {
      municipality: "Vancouver",
      country: "Canada",
      lat: 49.286610,
      lon: -123.118550
    }
  ]
)
