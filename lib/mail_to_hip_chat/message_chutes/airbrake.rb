require "mail_to_hip_chat/message_chute"
require "mustache"

module MailToHipChat
  module MessageChutes
    class Airbrake
      include MessageChute
      
      def call(params)
        return false unless process_message(params["plain"])
        true
      end

    private
      
      def airbrake_domain
        "airbrake.io"
      end
      
      def extraction_expression
        %r[\A\n+Project:\s([^\n]+)\n+     # Pull out the project name
                Environment:\s([^\n]+)\n+ # Pull out the project environment
                # Pull out the URL to the exception
                ^(http://[^.]+\.#{Regexp.escape(airbrake_domain)}/errors/\d+)\n+
                # Pull out the first line of the error message
                Error\sMessage:\n-{14}\n([^\n]+)]mx
      end
      
      def hipchat_sender
        "Airbrake"
      end
      
      def message_template
        %q[<b>{{project}} - {{environment}}</b><br /><a href="{{url}}">{{message}}</a>]
      end
      
      def process_message(plaintext)
        return nil unless parts = extract_parts(plaintext)
        send_notifications(parts)
        true
      end
                                     
      def extract_parts(plaintext)
        return nil unless parts = plaintext.match(extraction_expression)
        [:project, :environment, :url, :message].each_with_index.inject({}) do |hash,(key,idx)|
          hash[key] = parts[idx + 1]
          hash
        end
      end
      
      def send_notifications(message_parts)
        hipchat_message = Mustache.render(message_template, message_parts)
        message_rooms(hipchat_sender, hipchat_message)
      end
      
    end
  end
end