require "mail_to_hip_chat/rack_app/builder"
require "mail_to_hip_chat/chute_chain"
require "mail_to_hip_chat/exceptions"
require "rack/request"
require "digest/md5"

module MailToHipChat
  class RackApp
    SIGNATURE_PARAM_NAME = "signature"
  
    def initialize(opts = {})
      @secret      = opts[:secret]
      @chute_chain = opts[:chute_chain] || ChuteChain.new
    
      yield(self) if block_given?
    end
  
    def call(rack_env)
      request = Rack::Request.new(rack_env)
      return [400, {}, 'Bad Request.'] unless valid_request?(request)

      if @chute_chain.accept(request.params)
        [200, {}, 'OK']
      else
        [404, {}, 'Not Found.']
      end
    
    rescue Exception => error
      error.extend(InternalError)
      raise error
    end
  
    def use_chute(chute)
      @chute_chain.push(chute)
    end
  
  private
  
    def valid_request?(request)
      computed_sig = create_sig_from_params(request.params)

      computed_sig == request.params[SIGNATURE_PARAM_NAME]
    end


    def create_sig_from_params(params)
      sorted_param_names = params.keys.sort
      sorted_param_names.delete(SIGNATURE_PARAM_NAME)
    
      param_vals_with_secret = params.values_at(*sorted_param_names)
      param_vals_with_secret.push(@secret)
    
      Digest::MD5.hexdigest(param_vals_with_secret.join)
    end
  
  end
end