require 'spec_helper'

class Includer
  include Travian::Agent
end

module Travian
  describe Agent do
    describe '#request' do
      let(:agent) { Includer.new }

      context 'given connection is successfull' do
        it 'calls HTTParty.get when passed :get' do
          fake 'www.travian.com'
          HTTParty.should_receive(:get).with('http://www.travian.com/', timeout: 6)
          agent.send(:request, :get, 'http://www.travian.com/')
          unfake
        end

        it 'calls HTTParty.post when passed :post' do
          fake 'www.travian.com/serverLogin.php', :post
          HTTParty.should_receive(:post).with('http://www.travian.com/serverLogin.php', timeout: 6)
          agent.send(:request, :post, 'http://www.travian.com/serverLogin.php')
          unfake
        end
      end

      context 'given the connection fails' do
        it "should retry the connection #{Agent::MAX_TRIES} times when it raised SocketError" do
          host = 'http://www.travian.pt/'
          HTTParty.should_receive(:get).exactly(Agent::MAX_TRIES).times.and_raise(SocketError)
          expect { agent.get(host) }.to raise_exception(
            ConnectionTimeout,
            /Error connecting to '#{host}' \(/
          )
        end

        it "should retry the connection #{Agent::MAX_TRIES} times when it raised Errno::ETIMEDOUT" do
          host = 'http://www.travian.pt/'
          HTTParty.should_receive(:get).exactly(Agent::MAX_TRIES).times.and_raise(Errno::ETIMEDOUT)
          expect { agent.get(host) }.to raise_exception(
            ConnectionTimeout,
            /Error connecting to '#{host}' \(/
          )
        end

        it "should retry the connection #{Agent::MAX_TRIES} times when it raised Timeout::Error" do
          host = 'http://www.travian.pt/'
          HTTParty.should_receive(:get).exactly(Agent::MAX_TRIES).times.and_raise(Timeout::Error)
          expect { agent.get(host) }.to raise_exception(
            ConnectionTimeout,
            /Error connecting to '#{host}' \(/
          )
        end
      end
    end
    
  end
end
