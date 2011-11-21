require "mail_to_hip_chat/rack_app"
require "rack/builder"
require "rack/urlmap"
require "rack/commonlogger"

module MailToHipChat
  class RackApp
    class Builder
      attr_accessor :secret, :rooms, :api_token, :mount_point
      
      def initialize
        @chutes = []
        @mount_point = '/notifications/create'
        yield(self) if block_given?
      end
      
      def use_chute(chute_klass)
        @chutes << chute_klass
      end
      
      def to_app
        return @app if @app
        app = build_app
        mnt = mount_point
        @app = Rack::Builder.new do
          use Rack::CommonLogger
          map(mnt) { run app }
        end.to_app
      end
      
    private

      def build_app
        MailToHipChat::RackApp.new(:secret => @secret) do |f|
          @chutes.each do |chute_klass|
            f.use_chute(chute_klass.new(:api_token => @api_token, :rooms => split_rooms))
          end
        end
      end

      def split_rooms
        @rooms.split(/,\s*/)
      end
      
    end
  end
end