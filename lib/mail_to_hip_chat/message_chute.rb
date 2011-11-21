require "hipchat-api"

module MailToHipChat
  # Helpers for building a message chute. A message chute is something that responds to #call, and returns true if it's 
  # able to deliver the message off to HipChat. A chute can be something as simple as a Proc object. The ones this
  # gem ship with are small classes that make use of this module.
  module MessageChute
    
    # @param  [Hash] opts                   The options to create a message chute with
    # @option opts   [Array, String] :rooms A room or an array of rooms to send messages to
    def initialize_hipchat_opts(opts)
      @rooms       = Array(opts[:rooms])
      @hipchat_api = opts[:hipchat_api] || HipChat::API.new(opts[:api_token])
    end
    
  private
    
    # @param [#to_s] from     The sender the message will show up as being from in HipChat
    # @param [#to_s] message  The message to send
    def message_rooms(from, message)
      @rooms.each do |room_id| 
        @hipchat_api.rooms_message(room_id, from, message)
      end
    end
    
  end
end