require "test_helper"
require "mail_to_hip_chat/message_chute"

class MessageChuteTest < Test::Unit::TestCase
  class TestMessageChute
    include MailToHipChat::MessageChute
   
    def call(params) 
      message_rooms(params[:sender], params[:message])
    end
  end
    
  def setup
    @hipchat_api = mock
  end
  
  test "message_rooms uses the hipchat api to message the given room" do
    message_chute = TestMessageChute.new(:hipchat_api => @hipchat_api, :rooms => "123")
    @hipchat_api.expects(:rooms_message).with('123', "TestMessageChute", "example")
    message_chute.call(:sender => "TestMessageChute", :message => "example")
  end

  test "message_rooms uses the hipchat api to message all given rooms" do
    message_chute = TestMessageChute.new(:hipchat_api => @hipchat_api, :rooms => ["123", "456"])
    
    room_messages = sequence('room messages')
    @hipchat_api.expects(:rooms_message).with('123', "TestMessageChute", "example").in_sequence(room_messages)
    @hipchat_api.expects(:rooms_message).with('456', "TestMessageChute", "example").in_sequence(room_messages)
    
    message_chute.call(:sender => "TestMessageChute", :message => "example")    
  end

end