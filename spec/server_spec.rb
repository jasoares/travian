require 'spec_helper'

module Travian
  describe Server do
    context 'given the tx3.travian.pt server' do
      fake 'tx3.travian.pt'
      before(:each) do
        @server = Server.new('http://tx3.travian.pt/', 'tx3', 'Speed3x', Date.new(2012,9,29), 3113)
      end

      subject { @server }

      its(:host) { should == 'http://tx3.travian.pt/' }

      its(:code) { should == 'tx3' }

      its(:subdomain) { should == 'tx3' }

      its(:name) { should == 'Speed3x' }

      its(:start_date) { should == Date.new(2012,9,29) }

      its(:players) { should == 3113 }

      its(:world_id) { should == 'ptx18' }

      its(:speed) { should be 3 }

      its(:version) { should == "4.0" }

      describe '#attributes' do
        it 'should return a hash with the server\'s attributes' do
          @server.attributes.should == {
            host: 'http://tx3.travian.pt/',
            code: 'tx3',
            name: 'Speed3x',
            start_date: Date.new(2012,9,29),
            world_id: 'ptx18',
            speed: 3,
            version: '4.0'
          }
        end
      end

      shared_examples 'a proxy' do
        it 'should only need to call Server#load_info once and cache the info' do
          @server.should_receive(:load_info).once.and_call_original
          @server.send(method); @server.send(method)
        end
      end

      describe '#world_id' do
        let(:method) { :world_id }
        it_should_behave_like 'a proxy'
      end

      describe '#version' do
        let(:method) { :version }
        it_should_behave_like 'a proxy'
      end

      describe '#speed' do
        let(:method) { :speed }
        it_should_behave_like 'a proxy'
      end

      describe '#classic?' do
        it 'returns true when called on a classic server like tcx8.travian.de' do
          server = Server.new('http://tcx8.travian.de/', 'tcx8', 'Speed8x', Date.new(2012,12,11), 6911)
          server.classic?.should be true
        end

        it 'returns true when called on a classic server like tc27.travian.my' do
          server = Server.new('http://tc27.travian.my/', 'tc27', 'Classic Server 27', Date.new(2012,12,11), 6911)
          server.classic?.should be true
        end

        it 'returns false when called on a speed server like tx3.travian.com.br' do
          server = Server.new('http://tx3.travian.com.br/', 'tx3', 'Speed3x', Date.new(2012,12,11), 6911)
          server.classic?.should be false
        end

        it 'returns false when called on a normal server like ts4.travian.pt' do
          server = Server.new('http://ts4.travian.pt/', 'ts4', 'Servidor 4', Date.new(2012,12,11), 6911)
          server.classic?.should be false
        end
      end
    end

    describe '.fetch_server_data' do
      it 'raises Travian::ConnectionTimeout if server is offline' do
        server = Server.new('http://tx3.travian.com.br/', 'tx3', 'Speed3x', Date.new(2012,12,11), 6911)
        expect { server.send :fetch_server_data }.to raise_error(Travian::ConnectionTimeout)
      end
    end

    describe '.new' do
      context 'when passed a symbol code' do
        fake 'tx3.travian.pt'
        before(:each) do
          @server = Server.new('http://tx3.travian.pt/', :tx3, 'Speed3x', Date.new(2012,9,29), 3113)
        end

        subject { @server }

        its(:code) { should == 'tx3' }
      end
    end
  end
end
