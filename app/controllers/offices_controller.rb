class OfficesController < ApplicationController
  def index
    @offices = Office.all
    @offices.each(&:update_weather_data)
  end

  def show
    @office = Office.find(params[:id])
    @office.update_weather_data
  end
end
