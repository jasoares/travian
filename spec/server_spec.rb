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

    shared_examples 'a proxy to .server_data' do
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
      it_behaves_like 'a proxy to .server_data'
    end

    describe '#speed' do
      let(:method) { :speed }
      it_behaves_like 'a proxy to .server_data'
    end

    describe '#version' do
      let(:method) { :version }
      it_behaves_like 'a proxy to .server_data'
    end

    describe '#restart_date' do
      let(:method) { :restart_date }
      it_behaves_like 'a proxy to .server_data'
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
        instance.stub(restart_date: Date.today.to_datetime)
        instance.should be_restarting
      end

      it 'returns false if #restart_date is nil' do
        instance.stub(restart_date: nil)
        instance.should_not be_restarting
      end
    end

    describe '#running?' do
      it 'returns true if #start_date is not nil' do
        instance.stub(start_date: Date.today.to_datetime)
        instance.should be_running
      end

      it 'returns false if #start_date is nil' do
        instance.stub(start_date: nil)
        instance.should_not be_running
      end
    end

    describe '#ended?' do
      it 'returns true if #restarting? is true' do
        instance.stub(restarting?: true)
        instance.should be_ended
      end

      it 'returns true if #start_date is nil' do
        instance.stub(restarting?: false, start_date: nil)
        instance.should be_ended
      end

      it 'returns false when both #restarting is false and #start_date is not nil' do
        instance.stub(restarting?: false, start_date: Date.today.to_datetime)
        instance.should_not be_ended
      end
    end

    describe '.new' do
      it 'raises ArgumentError when passed nil as the hub' do
        expect { Server.new(nil) }.to raise_error(
          ArgumentError,
          /Must provide a host./
        )
      end
    end
  end
end
