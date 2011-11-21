require "test_helper"
require "mail_to_hip_chat/rack_app"

class RackAppConvenienceTest < Test::Unit::TestCase

  test "a tagged exception is raised if a chute raises an exception" do
    rack_app = MailToHipChat::RackApp.new
    rack_app.use_chute(lambda { |params| raise })
    assert_raise(MailToHipChat::InternalError) do
      rack_app.call(Rack::Request.new({}))
    end
  end
  
  test "use_chute is sugar for pushing onto the chute chain" do
    chute_chain, chute = mock, lambda {}
    chute_chain.expects(:push).with(chute)
    rack_app = MailToHipChat::RackApp.new(:chute_chain => chute_chain)
    rack_app.use_chute(chute)
  end
  
  test "the constructor yields self if a block is given as sugar for configuring the chutes" do
    rack_app_from_block = nil
    rack_app = MailToHipChat::RackApp.new { |app| rack_app_from_block = app}
    assert_equal rack_app, rack_app_from_block
  end
end

class RackAppRequestTest < Test::Unit::TestCase
  include RackEnvHelper
  
  def setup
    @rack_env = rack_env_from_fixture('test_email_request_dump')
  end
  
  test "a request signed with a different secret returns a 400 error" do
    rack_app = MailToHipChat::RackApp.new(:secret => "weird secret")
    response = rack_app.call(@rack_env)
    assert_equal 400, response[0]
  end

  test "a request signed with the same secret returns a 404 if no chute accepts it" do
    rack_app = MailToHipChat::RackApp.new(:secret => "bcfe2d24c306ceabf4f1")
    response = rack_app.call(@rack_env)
    assert_equal 404, response[0]
  end
  
  test "a request signed with the same secret returns a 200 if a chute accepts it" do
    rack_app = MailToHipChat::RackApp.new(:secret => "bcfe2d24c306ceabf4f1")
    rack_app.use_chute(lambda { |params| true })
    response = rack_app.call(@rack_env)
    assert_equal 200, response[0]
  end
  
end