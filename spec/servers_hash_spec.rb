require 'spec_helper'

module Travian
  describe ServersHash do
    let(:klass) { ServersHash }
    let(:servers_hash) do
      {
        ts1: { host: 'http://ts1.travian.pt/', name: 'Servidor 1', start_date: Date.today.to_datetime, players: 1298 },
        ts2: { host: 'http://ts2.travian.pt/', name: 'Servidor 2', start_date: Date.today.to_datetime, players: 1670 }
      }
    end
    let(:instance) { ServersHash.new(servers_hash) }

    it 'should respond_to each' do
      instance.should respond_to :each
    end

    it 'should include Enumerable' do
      instance.should respond_to :map, :find, :select, :reject
    end

    subject  { instance }

    it { should_not have_key :ts3 }

    it { should have(2).servers }

    it { should_not be_empty }

    its(:size) { should be 2 }

    its(:keys) { should === [:ts1, :ts2] }

    describe '#<<' do
      it 'adds the passed server to the hash' do
        server = Server.new('ts3.travian.pt')
        expect { instance << server }.to change { instance[:ts3] }.from(nil).to(server)
      end
    end

    describe '.new' do
      it 'raises ArgumentError when passed an argument that is not a Hash' do
        expect { klass.new(123) }.to raise_error(ArgumentError)
      end
    end

    describe '.build' do
      let(:server) { double('Server', :classic? => false) }

      it 'returns a ServersHash object' do
        Server.stub(:new => server)
        klass.build(servers_hash).should be_a ServersHash
      end
      
      it 'calls Server.new to create server objects to store in the hash' do
        Server.stub(:new => server)
        klass.should_receive(:new).with(kind_of(Hash)).once
        klass.build(servers_hash)
      end

      it 'passed login data params to Server.new' do
        server = double('Server', classic?: false)
        server_data = servers_hash.map {|k,v| v.values }
        Server.should_receive(:new).with(*server_data.first).and_return server
        Server.should_receive(:new).with(*server_data.last).and_return server
        klass.build(servers_hash)
      end
    end
  end
end
