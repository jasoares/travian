require 'spec_helper'

module Travian
  class AgentIncluder
    include Agent
  end

  describe Agent do
    let(:agent) { AgentIncluder.new }

    describe '#login_data' do
      before(:all) { fake 'www.travian.pt/serverLogin.php', :post }

      it 'makes a post request to the passed host' do
        agent.should_receive(:post).with('http://www.travian.pt/serverLogin.php').and_call_original
        agent.login_data('http://www.travian.pt/')
      end

      it 'returns the response body wrapped in a Nokogiri::HTML::Document' do
        agent.login_data('http://www.travian.pt/').should be_a Nokogiri::HTML::Document
      end

      after(:all) { unfake }
    end

    describe '#hubs_data' do
      before(:all) { fake 'www.travian.com' }

      it 'returns the response body wrapped in a Nokogiri::HTML::Document' do
        agent.hubs_data.should be_a Nokogiri::HTML::Document
      end

      after(:all) { unfake }
    end

    describe '#request' do
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
