module MailToHipChat
  # A {ChuteChain} is used to hold a collection of chutes and to check whether any of those chutes is
  # able to handle a message to hand off to HipChat. Anything that responds to #call can be pushed
  # onto the chain.
  class ChuteChain
    
    def initialize
      @chutes = []
    end

    # Pushes a chute onto the chain.
    #
    # @param [#call] chute The chute to push onto the chain.
    #
    # @return [self]
    def push(chute)
      @chutes.push(chute)
      self
    end
    
    # Takes in a message and traverses the chain looking for a chute that will handle it.
    #
    # @param [Hash] message The message to give to the chutes in the chain.
    #
    # @return [true]  True if a chute accepts the message.
    # @return [false] False if no chute can accept the message.
    def accept(message)
      @chutes.any? { |chute| chute.call(message) }
    end
    
  end
end
