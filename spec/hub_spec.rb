require 'spec_helper'

module Travian
  describe Hub do
    let(:net_hub) { Hub.new(:net, 'http://www.travian.net/') }
    let(:mx_hub) { Hub.new(:mx, 'http://www.travian.com.mx/') }
    let(:kr_hub) { Hub.new(:kr, 'http://www.travian.co.kr/') }
    let(:nz_hub) { Hub.new(:nz, 'http://www.travian.co.nz/') }
    let(:au_hub) { Hub.new(:au, 'http://www.travian.com.au/') }
    let(:com_hub) { Hub.new(:com, 'http://www.travian.com/') }
    let(:cl_hub) { Hub.new(:cl, 'http://www.travian.cl/') }
    let(:no_hub) { Hub.new(:no, 'http://www.travian.no/') }
    let(:ir_hub) { Hub.new(:ir, 'http://www.travian.ir/') }

    subject { net_hub }

    its(:code) { should == :net }

    its(:host) { should == 'http://www.travian.net/' }

    its(:name) { should == 'Spain' }

    describe '#language' do
      it 'returns \'es\' when called on the spanish hub' do
        net_hub.language.should == 'es'
      end

      it 'returns \'no\' when called on the norwegian hub' do
        no_hub.language.should == 'no'
      end
    end

    describe '#attributes' do
      subject { net_hub.attributes }

      it { should have_key :code }
      it { should have_key :host }
      it { should have_key :name }
      it { should have_key :language }
    end

    describe '#mirror?' do
      it 'should be false when it is neither redirected or borrows servers' do
        net_hub.stub(:redirected? => false)
        net_hub.stub(:borrows_servers? => false)
        net_hub.should_not be_mirror
      end

      it 'should be true when it is redirected' do
        nz_hub.stub(:redirected? => true)
        nz_hub.should be_mirror
      end

      it 'should not call borrows_servers if it is redirected' do
        kr_hub.stub(:redirected? => true)
        kr_hub.should_not_receive :borrows_servers?
        kr_hub.mirror?
      end

      it 'should be true when it is not redirected but it borrows_servers' do
        mx_hub.stub(:redirected? => false)
        mx_hub.stub(:borrows_servers? => true)
        mx_hub.should be_mirror
      end
    end

    describe '#mirrored_hub' do
      before(:all) do
        fake 'www.travian.com'
        fake 'www.travian.net/serverLogin.php', :post
        fake 'www.travian.com.mx/serverLogin.php', :post
      end

      it 'should be nil when called on the spanish hub' do
        net_hub.stub(location: net_hub.host)
        net_hub.mirrored_hub.should be nil
      end

      it 'returns the australian hub when called on the new zealand hub' do
        nz_hub.stub(location: au_hub.host)
        nz_hub.mirrored_hub.should == au_hub
      end

      it 'returns the chilean hub when called on the mexican hub' do
        mx_hub.stub(location: mx_hub.host)
        mx_hub.mirrored_hub.should == cl_hub
      end

      it 'returns the international hub when called on the south korea hub' do
        kr_hub.stub(location: com_hub.host)
        kr_hub.mirrored_hub.should == com_hub
      end

      after(:all) { unfake }
    end

    describe '#location' do
      it 'returns "http://www.travian.net/" when called on the spanish hub' do
        fake 'www.travian.net'
        net_hub.location.should == net_hub.host
      end

      it 'returns "http://www.travian.com.au/" when called on the new zealand hub' do
        fake_redirection 'www.travian.co.nz' => 'www.travian.com.au'
        nz_hub.location.should == au_hub.host
      end

      it 'returns "http://www.travian.com.mx/" when called on the mexican hub' do
        fake 'www.travian.com.mx'
        mx_hub.location.should == mx_hub.host
      end

      it 'returns "http://www.travian.com/" when called on the korean hub' do
        fake_redirection 'www.travian.co.kr' => 'www.travian.com'
        kr_hub.location.should == com_hub.host
      end

      after(:all) { unfake }
    end

    describe '#servers' do
      before(:all) do
        fake 'www.travian.net'
        fake 'www.travian.net/serverLogin.php', :post
        fake_redirection 'www.travian.co.nz' => 'www.travian.com.au'
        fake_redirection 'www.travian.co.kr' => 'www.travian.com'
        fake 'www.travian.com/serverLogin.php', :post
        fake 'www.travian.com.au/serverLogin.php', :post
      end

      it 'returns a ServersHash object' do
        net_hub.servers.should be_a ServersHash
      end

      it 'returns a ServersHash object with 9 servers when called on the spanish hub' do
        net_hub.servers.should have(9).servers
      end

      it 'returns a ServersHash object with 4 servers when called on the new zealand hub' do
        nz_hub.servers.should have(4).servers
      end

      it 'passes itself to ServersHash.build when called on the spanish hub' do
        ServersHash.should_receive(:build).with(net_hub)
        net_hub.servers
      end

      it 'passes the mirrored hub to ServersHash.build when called on the korean hub' do
        ServersHash.should_receive(:build).with(com_hub)
        kr_hub.servers
      end

      it 'passes the mirrored hub to ServersHash.build when called on the new zealand hub' do
        ServersHash.should_receive(:build).with(au_hub)
        nz_hub.servers
      end

      it 'should proxy the call to ServersHash' do
        ServersHash.should_receive(:build).once.and_call_original
        net_hub.servers
        net_hub.servers
      end

      after(:all) { unfake }
    end

    describe '#==' do
      it 'should compare based on code and host' do
        net_hub.should == Hub.new(:net, 'http://www.travian.net/')
      end
    end

    describe '#redirected?' do
      it 'returns false when called on the spanish hub' do
        net_hub.stub(location: 'http://www.travian.net/')
        net_hub.should_not be_redirected
      end

      it 'returns true when called on the New Zealand hub' do
        nz_hub.stub(location: 'http://www.travian.com.au/')
        nz_hub.should be_redirected
      end

      it 'returns false when called on the mexican hub' do
        mx_hub.stub(location: 'http://www.travian.com.mx/')
        mx_hub.should_not be_redirected
      end

      it 'returns true when called on the south korean hub' do
        kr_hub.stub(location: 'http://www.travian.com/')
        kr_hub.should be_redirected
      end
    end

    describe '#borrows_servers?', online: true do
      before(:all) { FakeWeb.allow_net_connect = true }

      it 'returns false when called on the spanish hub' do
        net_hub.send(:borrows_servers?).should be false
      end

      it 'returns false when called on the New Zealand hub' do
        nz_hub.send(:borrows_servers?).should be true
      end

      it 'returns true when called on the Mexican hub' do
        mx_hub.send(:borrows_servers?).should be true
      end

      it 'returns false when called on a hub with no servers' do
        ir_hub.stub(:servers => ServersHash.new({}))
        ir_hub.send(:borrows_servers?).should be false
      end

      after(:all) { FakeWeb.allow_net_connect = false }
    end

    describe '.[]' do
      before(:all) { fake 'www.travian.com' }
      it 'returns a hub when passed an object that responds to :code with a valid string' do
        obj = double('Object', code: 'pt')
        Hub[obj].should == Travian.hubs[:pt]
      end

      it 'returns a hub when passed a valid hub code as a Symbol' do
        Hub[:pt].should == Travian.hubs[:pt]
      end

      it 'returns a hub when passed a valid hub code as a String' do
        Hub['pt'].should == Travian.hubs[:pt]
      end

      it 'returns an array of keys when passed an invalid symbol or string' do
        Hub['es'].should == Hub::CODES.keys
      end

      it 'raises ArgumentError when passed an object thad does not respond to :code' do
        obj = double('Object')
        expect { Hub[obj] }.to raise_error(ArgumentError)
      end

      after(:all) { unfake }
    end

    describe '.valid?' do
      it 'returns true when passed a valid code Symbol' do
        Hub.valid?(:pt).should be true
      end

      it 'returns true when passed a valid code String' do
        Hub.valid?('net').should be true
      end

      it 'returns false when passed an invalid code' do
        Hub.valid?('es').should be false
      end
    end

  end
end
