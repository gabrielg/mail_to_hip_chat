require "mail_to_hip_chat/message_chute"
require "mustache"

module MailToHipChat
  module MessageChutes
    # Takes a test email and sends it to the configured HipChat rooms, to verify a deployment based on this library
    # is working.
    class TestEmail
      include MessageChute
      
      def initialize(opts)
        initialize_hipchat_opts(opts)
      end
      
      def call(params)
        return false unless params["subject"] =~ /testing setup/i
        message = Mustache.render("Message:<br />{{message}}", :message => params["plain"])
        message_rooms("Testing", message)
        true
      end
      
    end
  end
end