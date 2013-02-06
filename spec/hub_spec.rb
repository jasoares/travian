require 'spec_helper'

module Travian
  describe Hub do
    let(:hub) { Hub.new(:net, 'www.travian.net') }

    subject { hub }

    its(:code) { should == :net }

    its(:host) { should == 'www.travian.net' }

    its(:name) { should == 'Spain' }

    its(:language) { should == 'es' }

    describe '#attributes' do
      subject { hub.attributes }

      it { should have_key :code }
      it { should have_key :host }
      it { should have_key :name }
      it { should have_key :language }
    end

    describe '#mirror?' do
      it 'should be false when it is neither redirected or borrows servers' do
        hub.stub(redirected?: false, borrows_servers?: false)
        hub.should_not be_mirror
      end

      it 'should be true when it is redirected' do
        hub.stub(:redirected? => true)
        hub.should be_mirror
      end

      it 'should not call borrows_servers if it is redirected' do
        hub.stub(:redirected? => true)
        hub.should_not_receive :borrows_servers?
        hub.mirror?
      end

      it 'should be true when it is not redirected but it borrows servers' do
        hub.stub(redirected?: false, borrows_servers?: true)
        hub.should be_mirror
      end
    end

    describe '#mirrored_hub' do
      it 'should be nil when called on a non mirror hub' do
        hub.stub(mirror?: false)
        hub.mirrored_hub.should be nil
      end

      it 'returns the mirrored hub when called on a mirror hub' do
        hub.stub(mirror?: true, mirrored_host: 'www.travian.com')
        mirrored = Hub.new(:com, 'www.travian.com')
        Travian.stub_chain(:hubs, :find).and_return(mirrored)
        hub.mirrored_hub.should == mirrored
      end
    end

    describe '#mirrored_host' do
      it 'should be nil when called on a non mirror hub' do
        hub.stub(mirror?: false)
        hub.mirrored_host.should be nil
      end

      it 'returns the location when called on a redirected hub' do
        hub.stub(mirror?: true, redirected?: true, location: "www.travian.com.au")
        hub.mirrored_host.should == "www.travian.com.au"
      end

      it 'returns a base host "www.travian." plus a server tld when called on a non redirected mirror' do
        hub.stub(mirror?: true, redirected?: false)
        hub.stub_chain(:servers, :first, :tld).and_return("cl")
        hub.mirrored_host.should == "www.travian.cl"
      end
    end

    describe '#location' do
      it 'returns the value from Agent.redirected_location unchanged' do
        Agent.stub(redirected_location: hub.host)
        hub.location.should == hub.host
      end

      it 'proxies the return value of Agent.redirected_location on successive calls' do
        Agent.should_receive(:redirected_location).with(hub.host).once.and_return(hub.host)
        hub.location
        hub.location
      end

      after(:all) { unfake }
    end

    describe '#servers' do
      it 'calls ServersHash.build with login_data and register_data merged' do
        hub.should_receive(:register_data).and_return({ ts1: { host: 'ts1.travian.pt' } })
        hub.should_receive(:login_data).and_return({ ts2: { host: 'ts2.travian.pt' } })
        ServersHash.should_receive(:build).with({ ts1: { host: 'ts1.travian.pt' }, ts2: { host: 'ts2.travian.pt' } })
        hub.servers
      end

      it 'proxies the return value' do
        hub.stub(login_data: {}, register_data: {})
        ServersHash.should_receive(:build).once.and_return({})
        hub.servers
        hub.servers
      end
    end

    describe '#==' do
      it 'should compare based on code and host' do
        hub.should == Hub.new(:net, 'www.travian.net')
      end
    end

    describe '#redirected?' do
      it 'returns false when location and host are equal' do
        hub.stub(location: 'www.travian.net')
        hub.should_not be_redirected
      end

      it 'returns true when location and host are different' do
        hub.stub(location: 'www.travian.com.au')
        hub.should be_redirected
      end
    end

    describe '#borrows_servers?' do
      it 'returns false when called on a hub with no servers' do
        hub.stub_chain(:servers, :empty?).and_return(true)
        hub.send(:borrows_servers?).should be false
      end

      it "is false when the hub has servers and its tld is equal to the servers tld" do
        hub.stub_chain(:servers, :empty?).and_return(false)
        hub.stub_chain(:servers, :first, :tld).and_return('net')
        hub.stub(tld: 'net')
        hub.send(:borrows_servers?).should be false
      end

      it 'returns true when the hub has servers and their tlds is different from hubs' do
        hub.stub_chain(:servers, :empty?).and_return(false)
        hub.stub_chain(:servers, :first, :tld).and_return('cl')
        hub.stub(tld: 'com.mx')
        hub.send(:borrows_servers?).should be true
      end
    end

    describe '.new' do
      it 'raises an ArgumentError when passed an invalid code' do
        expect { Hub.new(:ic, 'www.travian.ic') }.to raise_error(ArgumentError)
      end

      it 'accepts a string code' do
        hub = double('Hub', code: 'de', host: 'www.travian.de')
        expect { Hub.new(:de, 'www.travian.de') }.not_to raise_error
      end

      it 'accepts a symbol code' do
        expect { Hub.new('de', 'www.travian.de') }.not_to raise_error
      end
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
