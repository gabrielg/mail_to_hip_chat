require "hipchat-api"

module MailToHipChat
  module MessageChute

    def initialize(opts)
      @rooms       = Array(opts[:rooms])
      @hipchat_api = opts[:hipchat_api] || HipChat::API.new(opts[:api_token])
    end
    
  private
    
    def message_rooms(from, message)
      @rooms.each do |room_id| 
        @hipchat_api.rooms_message(room_id, from, message)
      end
    end
    
  end
end