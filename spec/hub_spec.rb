require 'spec_helper'

module Travian
  describe Hub do
    context 'given a sample spanish hub' do
      before(:each) do
        @hub = Hub.new(:net, 'http://www.travian.net/')
      end

      subject { @hub }

      its(:code) { should == :net }

      its(:host) { should == 'http://www.travian.net/' }

      its(:name) { should == 'Spain' }

      its(:attributes) { should == {code: 'net', host: 'http://www.travian.net/', name: 'Spain', language: 'es' } }

      describe '#servers' do
        fake 'www.travian.net/serverLogin.php', :post
        it 'should delegate servers data fetching and parsing to ServersHash.build' do
          ServersHash.should_receive(:build).with(@hub)
          @hub.servers
        end

        it 'should return a ServersHash object' do
          @hub.servers.should be_a ServersHash
        end
      end

    end
  end
end
