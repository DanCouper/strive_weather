class OfficesController < ApplicationController
  def index
    @offices = OFFICES
  end

  def show
    @office = OFFICES.find { |office| office[:id] == params[:id] }
  end
end
