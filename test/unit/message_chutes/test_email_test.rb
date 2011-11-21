require "test_helper"
require "mail_to_hip_chat/message_chutes/test_email"

class TestEmailMessageChuteTest < Test::Unit::TestCase
  
  def setup
    @hipchat_api = mock
    @airbrake_chute = MailToHipChat::MessageChutes::TestEmail.new(:rooms => "123", :hipchat_api => @hipchat_api)
  end
  
  test "a message with 'Testing Setup' in the subject in mixed case forwards to hipchat" do
    @hipchat_api.expects(:rooms_message).with(anything, "Testing", "Message:<br />test &lt;1,2,3&gt;")
    assert @airbrake_chute.call("subject" => "TeStInG SeTuP", "plain" => "test <1,2,3>")    
  end

  test "a message with 'Testing Setup' anywhere in the subject forwards to hipchat" do
    @hipchat_api.expects(:rooms_message).with(anything, "Testing", "Message:<br />test &lt;1,2,3&gt;")
    assert @airbrake_chute.call("subject" => "i am testing setup", "plain" => "test <1,2,3>")
  end

end