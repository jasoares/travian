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
        agent.should_receive(:post).with('www.travian.pt/serverLogin.php', limit: 1).and_call_original
        agent.login_data('www.travian.pt')
      end

      it 'returns the response body wrapped in a Nokogiri::HTML::Document' do
        agent.login_data('www.travian.pt').should be_a Nokogiri::HTML::Document
      end

      it 'retries the post request to the new location when redirected' do
        fake_redirection({'www.travian.co.kr/serverLogin.php' => 'www.travian.com/serverLogin.php'}, :post)
        agent.should_receive(:post).with('www.travian.co.kr/serverLogin.php', limit: 1).once.and_call_original
        agent.should_receive(:post).with('www.travian.com/serverLogin.php', limit: 1).once
        agent.login_data('www.travian.co.kr')
      end

      it 'retries the post request to the new location when redirected and provided with only the host' do
        fake_redirection({'www.travian.co.nz/serverLogin.php' => 'www.travian.com.au'}, :post)
        agent.should_receive(:post).with('www.travian.co.nz/serverLogin.php', limit: 1).and_call_original
        agent.should_receive(:post).with('www.travian.com.au/serverLogin.php', limit: 1)
        agent.login_data('www.travian.co.nz')
      end

      after(:all) { unfake }
    end

    describe '#redirected_location' do
      it 'calls post with the host plus the "/register.php" path and limit: 1 option' do
        fake 'www.travian.com/register.php', :post
        agent.should_receive(:post).with('www.travian.com/register.php', limit: 1).and_call_original
        agent.redirected_location('www.travian.com')
      end

      it 'returns the host when no redirection happens' do
        fake 'www.travian.com/register.php', :post
        agent.redirected_location('www.travian.com').should == 'www.travian.com'
      end

      it 'returns the new location when it receives a redirected response' do
        fake_redirection({'www.travian.co.nz/register.php' => 'www.travian.com.au'}, :post)
        agent.redirected_location('www.travian.co.nz').should == 'www.travian.com.au'
      end

      it 'strips the protocol and the path or trailing root slash' do
        fake_redirection({'www.travian.co.kr/register.php' => 'www.travian.com/register.php'}, :post)
        agent.redirected_location('www.travian.co.kr').should == 'www.travian.com'
      end
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
          HTTParty.should_receive(:get).with('http://www.travian.com', timeout: 6)
          agent.send(:request, :get, 'www.travian.com')
          unfake
        end

        it 'calls HTTParty.post when passed :post' do
          fake 'www.travian.com/serverLogin.php', :post
          HTTParty.should_receive(:post).with('http://www.travian.com/serverLogin.php', timeout: 6)
          agent.send(:request, :post, 'www.travian.com/serverLogin.php')
          unfake
        end
      end

      context 'given the connection fails' do
        it "should retry the connection #{Agent::MAX_TRIES} times when it raised SocketError" do
          host = 'www.travian.pt'
          HTTParty.should_receive(:get).exactly(Agent::MAX_TRIES).times.and_raise(SocketError)
          expect { agent.get(host) }.to raise_exception(
            ConnectionTimeout,
            /Error connecting to '#{host}' \(/
          )
        end

        it "should retry the connection #{Agent::MAX_TRIES} times when it raised Errno::ETIMEDOUT" do
          host = 'www.travian.pt'
          HTTParty.should_receive(:get).exactly(Agent::MAX_TRIES).times.and_raise(Errno::ETIMEDOUT)
          expect { agent.get(host) }.to raise_exception(
            ConnectionTimeout,
            /Error connecting to '#{host}' \(/
          )
        end

        it "should retry the connection #{Agent::MAX_TRIES} times when it raised Errno::ECONNREFUSED" do
          host = 'www.travian.pt'
          HTTParty.should_receive(:get).exactly(Agent::MAX_TRIES).times.and_raise(Errno::ECONNREFUSED)
          expect { agent.get(host) }.to raise_exception(
            ConnectionTimeout,
            /Error connecting to '#{host}' \(/
          )
        end

        it "should retry the connection #{Agent::MAX_TRIES} times when it raised Timeout::Error" do
          host = 'www.travian.pt'
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
