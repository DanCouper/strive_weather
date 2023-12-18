require "test_helper"
require "faraday"

class ForecastServiceTest < ActiveSupport::TestCase
  test "expected response" do 
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
    end
  end
end
