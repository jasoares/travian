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

      describe '#is_mirror?' do
        fake 'www.travian.net/serverLogin.php', :post

        it 'should return false' do
          @hub.is_mirror?.should be false
        end
      end

      describe '#leads_to', online: true do
        it 'should return "http://www.travian.net/" as it does not redirect' do
          FakeWeb.allow { @hub.leads_to.should == "http://www.travian.net/" }
        end
      end

      describe '#==' do
        it 'should return true when passed a hub with the same host and code' do
          @hub.should == Hub.new(:net, 'http://www.travian.net/')
        end
      end

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

    context 'given a sample new zealand hub' do
      before(:each) do
        @hub = Hub.new(:nz, 'http://www.travian.co.nz/')
      end

      subject { @hub }

      its(:code) { should == :nz }

      its(:host) { should == 'http://www.travian.co.nz/' }

      its(:name) { should == 'New Zealand' }

      its(:attributes) { should == {code: 'nz', host: 'http://www.travian.co.nz/', name: 'New Zealand', language: 'en' } }

      describe '#is_mirror?' do
        fake 'www.travian.co.nz/serverLogin.php', :post

        it 'should return true' do
          @hub.is_mirror?.should be true
        end
      end

      describe '#leads_to', online: true do
        it 'should return "http://www.travian.com.au/" as it redirects' do
          FakeWeb.allow { @hub.leads_to.should == "http://www.travian.com.au/" }
        end
      end

      describe '#==' do
        it 'should return true when passed a hub with the same host and code' do
          @hub.should == Hub.new(:nz, 'http://www.travian.co.nz/')
        end
      end

      describe '#servers' do
        fake 'www.travian.co.nz/serverLogin.php', :post
        it 'should delegate servers data fetching and parsing to ServersHash.build' do
          ServersHash.should_receive(:build).with(@hub)
          @hub.servers
        end

        it 'should return a ServersHash object' do
          @hub.servers.should be_a ServersHash
        end
      end
    end

    context 'given a sample mexico hub' do
      before(:each) do
        @hub = Hub.new(:mx, 'http://www.travian.com.mx/')
      end

      subject { @hub }

      its(:code) { should == :mx }

      its(:host) { should == 'http://www.travian.com.mx/' }

      its(:name) { should == 'Mexico' }

      its(:attributes) { should == {code: 'mx', host: 'http://www.travian.com.mx/', name: 'Mexico', language: 'es' } }

      describe '#is_mirror?' do
        fake 'www.travian.com.mx/serverLogin.php', :post

        it 'should return true' do
          @hub.is_mirror?.should be true
        end
      end

      describe '#leads_to', online: true do
        it 'should return "http://www.travian.com.mx/" as it does not redirect' do
          FakeWeb.allow { @hub.leads_to.should == "http://www.travian.com.mx/" }
        end
      end

      describe '#==' do
        it 'should return true when passed a hub with the same host and code' do
          @hub.should == Hub.new(:mx, 'http://www.travian.com.mx/')
        end
      end

      describe '#servers' do
        fake 'www.travian.com.mx/serverLogin.php', :post
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
