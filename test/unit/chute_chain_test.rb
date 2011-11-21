require "test_helper"
require "mail_to_hip_chat/chute_chain"

class ChuteChainTest < Test::Unit::TestCase
  
  def setup
    @chute_chain = MailToHipChat::ChuteChain.new
  end
  
  test "pushing a chute returns the chute chain" do
    push_result = @chute_chain.push(lambda {})
    assert_equal @chute_chain, push_result
  end

  test "chutes are traversed in the order they're pushed into the chain" do
    chute_traversal = sequence('chute traversal')

    chain_head_chute, chain_tail_chute = mock, mock
    chain_head_chute.expects(:call).in_sequence(chute_traversal)
    chain_tail_chute.expects(:call).in_sequence(chute_traversal)

    @chute_chain.push(chain_head_chute).push(chain_tail_chute)
    @chute_chain.accept({})
  end
  
  test "traversing the chain stops at the first chute that returns a response" do
    chain_head_chute, chain_mid_chute, chain_tail_chute = mock, mock, mock
    
    chain_head_chute.expects(:call).returns(false)
    chain_mid_chute.expects(:call).returns(true)
    chain_tail_chute.expects(:call).never
    
    @chute_chain.push(chain_head_chute).push(chain_mid_chute).push(chain_tail_chute)                 
    @chute_chain.accept({})
  end
  
  test "traversing the chain calls each chute with the given params" do
    params = {:test => :params}
    
    chain_head_chute, chain_tail_chute = mock, mock
    chain_head_chute.expects(:call).with(params)
    chain_tail_chute.expects(:call).with(params)
    
    @chute_chain.push(chain_head_chute).push(chain_tail_chute)
    @chute_chain.accept(params)
  end
  
end