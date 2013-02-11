require 'spec_helper'

module Travian
  describe Server do
    let(:instance) { Server.new('tx3.travian.pt', 'Speed 3x', Date.today.to_datetime, 3103) }

    it 'should include UriHelper' do
      instance.should respond_to :tld, :subdomain, :hub_code, :server_code
    end

    subject { instance }

    its(:host) { should == 'tx3.travian.pt'}

    its(:name) { should == 'Speed 3x' }

    its(:start_date) { should == Date.today.to_datetime }

    its(:players) { should be 3103 }

    shared_examples 'a proxy to #server_data' do
      before(:each) do
        Agent.stub(:server_data)
        ServerData.stub(parse: ["4.0", "ptx18", 3, nil])
      end

      it 'only calls server_data once on successive calls' do
        instance.should_receive(:server_data).and_call_original
        instance.send(method)
        instance.send(method)
      end
    end

    describe '#hub' do
      before(:all) { fake 'www.travian.com' }

      it 'returns the hub object based on the hub_code' do
        instance.hub.should == Hub.new(:pt, 'www.travian.pt')
      end
    end

    describe '#world_id' do
      let(:method) { :world_id }

      it 'returns nil when called on a classic server' do
        Server.new('tc4.travian.pt').world_id.should be nil
      end

      it_behaves_like 'a proxy to #server_data'
    end

    describe '#speed' do
      let(:method) { :speed }

      it 'calls #classic_speed when called on a classic server' do
        instance.stub(code: 'tc4')
        instance.should_receive('classic_speed').and_return(1)
        instance.speed
      end

      it_behaves_like 'a proxy to #server_data'
    end

    describe '#version' do
      let(:method) { :version }

      it 'returns "3.6" when called on a classic server' do
        instance.stub(code: 'tc4')
        instance.version.should == "3.6"
      end

      it_behaves_like 'a proxy to #server_data'
    end

    describe '#restart_date' do
      let(:method) { :restart_date }

      it 'returns nil when called on a classic server' do
        instance.stub(code: 'tc4')
        instance.restart_date.should be nil
      end

      it_behaves_like 'a proxy to #server_data'
    end

    describe '#server_data' do
      it 'sets @version, @world_id, @speed and @restart_date values' do
        values = ["4.0", "ptx18", 3, Date.today.to_datetime]
        Agent.stub(:server_data)
        ServerData.stub(parse: values)
        expect {
          instance.send(:server_data)
        }.to change {
          instance.instance_eval("[@version, @world_id, @speed, @restart_date]")
        }.from([nil] * 4).to(values)
      end

      it 'returns an array of values' do
        values = ["4.0", "ptx18", 3, Date.today.to_datetime, 'server=ptx']
        Agent.stub(:server_data)
        ServerData.stub(parse: values)
        instance.send(:server_data).should == values
      end
    end

    describe '#server_register_data' do
      it 'calls Agent.register_data with the hub\'s host and the server_id' do
        instance.stub(server_id: 'server=pt4')
        instance.stub(hub: double('Hub', host: 'www.travian.pt'))
        RegisterData.stub(:parse_selected_name)
        Agent.should_receive(:register_data).with('www.travian.pt', 'server=pt4')
        instance.send(:server_register_data)
      end
    end

    describe '#code' do
      it 'returns tx3 when host is "tx3.travian.pt"' do
        instance.stub(host: 'tx3.travian.pt')
        instance.code.should == 'tx3'
      end

      it 'returns arabiatx4 when host is "arabiatx4.travian.com' do
        instance.stub(host: 'arabiatx4.travian.pt')
        instance.code.should == 'arabiatx4'
      end
    end

    describe '#attributes' do
      it 'returns a hash with the server\'s attributes' do
        instance.stub(host: 'tx3.travian.pt', code: 'tx3', name: 'Speed 3x', world_id: 'ptx18', speed: 3)
        instance.attributes.should == {
          host: 'tx3.travian.pt',
          code: 'tx3',
          name: 'Speed 3x',
          world_id: 'ptx18',
          speed: 3,
        }
      end
    end

    describe '#classic?' do
      let(:hub) { double('Hub') }

      it 'returns true when code is tcx8' do
        instance.stub(code: 'tcx8')
        instance.should be_classic
      end

      it 'returns true when code is tc27' do
        instance.stub(code: 'tc27')
        instance.should be_classic
      end

      it 'returns false when code is tx3' do
        instance.stub(code: 'tx3')
        instance.should_not be_classic
      end

      it 'returns false when code is ts4' do
        instance.stub(code: 'ts4')
        instance.should_not be_classic
      end
    end

    describe '#restarting?' do
      it 'returns true if #restart_date is not nil' do
        instance.stub(ended?: true, restart_date: Date.today.to_datetime)
        instance.should be_restarting
      end

      it 'returns false if #restart_date is nil' do
        instance.stub(ended?: true, restart_date: nil)
        instance.should_not be_restarting
      end

      it 'does not check the restart date if the server is running' do
        instance.stub(ended?: false)
        instance.should_not_receive(:restart_date)
        instance.restarting?
      end
    end

    describe '#running?' do
      it 'returns the opposite of ended?' do
        instance.stub(ended?: false)
        instance.should be_running
      end
    end

    describe '#ended?' do
      it 'returns true if #start_date is nil' do
        instance.stub(start_date: nil)
        instance.ended?.should be true
      end

      it 'returns false when #start_date is not nil' do
        instance.stub(start_date: Date.today.to_datetime)
        instance.ended?.should be false
      end
    end

    describe '#classic_speed' do
      it 'returns 8 given the code is "tcx8"' do
        instance.stub(code: 'tcx8')
        instance.send(:classic_speed).should == 8
      end

      it 'returns 1 given the code is "tc4"' do
        instance.stub(code: 'tc4')
        instance.send(:classic_speed).should == 1
      end
    end

    describe '.new' do
      it 'raises ArgumentError when passed nil as the host' do
        expect { Server.new(nil) }.to raise_error(
          ArgumentError,
          /Must provide a host./
        )
      end

      subject { Server.new('ts1.travian.pt') }

      its(:start_date) { should be nil }

      its(:players) { should be 0 }

    end
  end
end
