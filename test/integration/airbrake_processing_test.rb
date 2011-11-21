require "test_helper"
require "rack/builder"
require "rack/utils"

class AirbrakeProcessingTest < Test::Unit::TestCase
  include RackEnvHelper

  def setup
    WebMock.disable_net_connect!
    ENV['CLOUDMAILIN_SECRET'] = "6e50b93207454d57d587"
    ENV['HIPCHAT_ROOMS']      = "123"
    ENV['HIPCHAT_API_TOKEN']  = "example_auth_token"
    @app = app_from_config("support/config.ru")
    @airbrake_rack_env = rack_env_from_fixture("airbrake_request_dump")
  end
  
  def teardown
    WebMock.allow_net_connect!
  end
  
  test "an incoming request from airbrake via cloudmailin eventually posts to HipChat" do
    exception_url = "http://mailfunneltest.airbrake.io/errors/24746833"
    message = %Q[<b>Mail Funnel - Unknown</b><br /><a href="#{exception_url}">RuntimeError: Test Exception</a>]
                      
    stub_request(:post, "https://api.hipchat.com/v1/rooms/message").to_return(:status => 200)
    
    @app.call(@airbrake_rack_env)

    request_params = {"auth_token" => "example_auth_token", "from" => "Airbrake", "room_id" => "123", "message" => message}
    
    assert_requested(:post, "https://api.hipchat.com/v1/rooms/message") do |req|
      # Unfortunately, WebMock doesn't actually give me an easy way to check whether only certain
      # values I care about are in the request body. Hence, this mess.
      body_params = Rack::Utils.parse_query(req.body)
      request_params.all? {|k,v| body_params[k] == v}
    end
  end
  
private

  def app_from_config(config_file)
    app, options = Rack::Builder.parse_file(config_file, nil)
    app
  end

end