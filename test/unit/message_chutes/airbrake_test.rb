require "test_helper"
require "mail_to_hip_chat/message_chutes/airbrake"

class AirbrakeMessageChuteTest < Test::Unit::TestCase
  
  def setup
    @hipchat_api = mock
    @airbrake_chute = MailToHipChat::MessageChutes::Airbrake.new(:rooms => "123", :hipchat_api => @hipchat_api)
  end

  test "a message with a parseable body is accepted" do
    @hipchat_api.expects(:rooms_message).with(any_parameters)
    message = read_fixture("airbrake_exception_body")
    assert @airbrake_chute.call("plain" => message)
  end

  test "a message with an unparseable body is rejected" do
    assert !@airbrake_chute.call("plain" => "zzzzzzz")
  end
  
  test "the message sent to HipChat contains exception information" do
    project, environment = "Echelon", "Staging"
    message = "AirbrakeTestingException: Testing airbrake via &quot;rake airbrake:test&quot;. If you can see this, it works."
    url = "http://the-nsa.airbrake.io/errors/11082122"
    
    hipchat_message = %Q[<b>#{project} - #{environment}</b><br /><a href="#{url}">#{message}</a>]
    
    @hipchat_api.expects(:rooms_message).with(anything, anything, hipchat_message)
    
    @airbrake_chute.call("plain" => read_fixture("airbrake_exception_body"))
  end
  
  test "the message is sent to HipChat as coming from an Airbrake user" do
    @hipchat_api.expects(:rooms_message).with(anything, "Airbrake", anything)

    @airbrake_chute.call("plain" => read_fixture("airbrake_exception_body"))
  end

end