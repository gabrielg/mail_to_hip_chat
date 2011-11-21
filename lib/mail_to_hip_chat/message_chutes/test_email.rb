require "mail_to_hip_chat/message_chute"
require "mustache"

module MailToHipChat
  module MessageChutes
    class TestEmail
      include MessageChute
      
      def call(params)
        return false unless params["subject"] =~ /testing setup/i
        message = Mustache.render("Message:<br />{{message}}", :message => params["plain"])
        message_rooms("Testing", message)
        true
      end
      
    end
  end
end