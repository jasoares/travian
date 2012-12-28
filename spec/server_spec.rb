require 'spec_helper'

class FakeServer
  include Travian::Server
end

module Travian
  describe Server do
    shared_context 'load sample hub server data' do
      include_context 'fake pt serverLogin'
      before(:all) do
        hub = "host"; def hub.host; 'http://www.travian.pt/'; end
        @hub_server_data = Server.send(:fetch_hub_server_data, hub).first
      end
    end

    shared_context 'load sample server data' do
      include_context 'fake tx3.travian.pt'
      before(:all) do
        server = 'http://tx3.travian.pt/'
        @server_data = Server.send(:fetch_server_data, server)
      end
    end

    describe '#subdomain' do
      before(:each) do
        @server = FakeServer.new
      end

      it 'calls :host on the receiver' do
        @server.should_receive(:host) { 'http://ts1.travian.no/'}
        @server.subdomain
      end

      it 'delegates the to Server.parse_subdomain' do
        host = 'http://ts4.travian.dk/'
        @server.stub(:host => host)
        Server.should_receive(:parse_subdomain).with(host)
        @server.subdomain
      end
    end

    describe '.fetch_list!' do
      shared_examples 'fetcher' do
        before(:each) do
          @each_hub = Server.fetch_list!(@hub).values.first
        end

        subject { @each_hub }
        
        it { should have_key :host }

        it { should have_key :code }
        
        it { should have_key :name }
        
        it { should have_key :start_date }
        
        it { should have_key :world_id }
        
        it { should have_key :version }

        it { should have_key :speed }
      end

      context 'given the Czech Republic hub' do
        include_context 'fake czech hub and servers'

        before(:each) do
          @hub = double('Hub', :host => 'http://www.travian.cz/')
        end

        context 'when no block is passed' do
          include_examples 'fetcher'
        end
      end

      context 'given a hub with 10 servers, where one is a classic server' do
        include_context 'fake pt serverLogin'
        include_context 'fake portuguese hub and servers'

        before(:each) do
          @hub = double('Hub', :host => 'http://www.travian.pt/')
        end
  
        context 'when no block is passed' do
          include_examples 'fetcher'

          it 'should be a Hash' do
            Server.fetch_list!(@hub).should be_a Hash
          end
  
          it 'should have 9 keys' do
            Server.fetch_list!(@hub).should have(9).keys
          end
  
          let(:list) { Server.fetch_list!(@hub) }
        end
  
        context 'when passed a block' do
          before(:all) do
            Timecop.freeze(Time.utc(2012,12,27,10,20,0))
          end

          let(:list) { Server.fetch_list!(@hub) {} }
  
          it 'yields a hub hash of attributes to the block each turn' do
            expect {|b| Server.fetch_list!(@hub, &b) }.to yield_successive_args(*[
              ["ts1", {"host"=>"http://ts1.travian.pt/", "code"=>"ts1", "name"=>"Servidor1", "start_date"=> Date.new(2012,01,31), "world_id"=>"pt11", "version"=>"4.0", "speed"=>1}],
              ["ts10", {"host"=>"http://ts10.travian.pt/", "code"=>"ts10", "name"=>"Servidor10", "start_date"=> Date.new(2012,4,7), "world_id"=>"pt1010", "version"=>"4.0", "speed"=>1}],
              ["ts2", {"host"=>"http://ts2.travian.pt/", "code"=>"ts2", "name"=>"Servidor2", "start_date"=> Date.new(2012,7,14), "world_id"=>"pt22", "version"=>"4.0", "speed"=>1}],
              ["ts3", {"host"=>"http://ts3.travian.pt/", "code"=>"ts3", "name"=>"Servidor3", "start_date"=> Date.new(2012,5,26), "world_id"=>"pt33", "version"=>"4.0", "speed"=>1}],
              ["ts4", {"host"=>"http://ts4.travian.pt/", "code"=>"ts4", "name"=>"Servidor4", "start_date"=> Date.new(2012,8,30), "world_id"=>"pt44", "version"=>"4.0", "speed"=>1}],
              ["ts5", {"host"=>"http://ts5.travian.pt/", "code"=>"ts5", "name"=>"Servidor5", "start_date"=> Date.new(2011,12,3), "world_id"=>"pt55", "version"=>"4.0", "speed"=>1}],
              ["ts6", {"host"=>"http://ts6.travian.pt/", "code"=>"ts6", "name"=>"Servidor6", "start_date"=> Date.new(2012,10,18), "world_id"=>"pt66", "version"=>"4.0", "speed"=>1}],
              ["ts7", {"host"=>"http://ts7.travian.pt/", "code"=>"ts7", "name"=>"Servidor7", "start_date"=> Date.new(2012,12,8), "world_id"=>"pt77", "version"=>"4.0", "speed"=>1}],
              ["tx3", {"host"=>"http://tx3.travian.pt/", "code"=>"tx3", "name"=>"Speed3x", "start_date"=> Date.new(2012,9,29), "world_id"=>"ptx18", "version"=>"4.0", "speed"=>3}]
            ])
          end

          after(:all) do
            Timecop.return
          end
        end
      end
    end

    describe '.reject_classic_servers' do
      it 'should reject classic speed servers like http://tcx8.travian.de/' do
        servers = {'tcx8' => {'host' => 'http://tcx8.travian.de', 'code' => 'tcx8'}}
        Server.send(:reject_classic_servers, servers).should == {}
      end

      context 'when passed the czech hub' do
        include_context 'fake czech hub and servers'

        before(:each) do
          hub = double('Hub', :host => 'http://www.travian.cz/')
          @hubs_hash = Server.send(:fetch_hub_servers_data_in_hash, hub)
        end

        it 'should return a hash of servers without the classic servers' do
          Server.send(:reject_classic_servers, @hubs_hash).should == @hubs_hash
        end
      end

      context 'when passed the portuguese hub' do
        include_context 'fake portuguese hub and servers'

        before do
          Timecop.freeze(Time.utc(2012,12,27,10,20,0))
          hub = double('Hub', :host => 'http://www.travian.pt/')
          @hubs_hash = Server.send(:fetch_hub_servers_data_in_hash, hub)
        end

        it 'should return a hash of servers without the classic servers' do
          Server.send(:reject_classic_servers, @hubs_hash).should == {
            "ts1" => {"host"=>"http://ts1.travian.pt/", "code"=>"ts1", "name"=>"Servidor1", "start_date"=> Date.new(2012,01,31)},
            "ts10" => {"host"=>"http://ts10.travian.pt/", "code"=>"ts10", "name"=>"Servidor10", "start_date"=> Date.new(2012,4,7)},
            "ts2" => {"host"=>"http://ts2.travian.pt/", "code"=>"ts2", "name"=>"Servidor2", "start_date"=> Date.new(2012,7,14)},
            "ts3" => {"host"=>"http://ts3.travian.pt/", "code"=>"ts3", "name"=>"Servidor3", "start_date"=> Date.new(2012,5,26)},
            "ts4" => {"host"=>"http://ts4.travian.pt/", "code"=>"ts4", "name"=>"Servidor4", "start_date"=> Date.new(2012,8,30)},
            "ts5" => {"host"=>"http://ts5.travian.pt/", "code"=>"ts5", "name"=>"Servidor5", "start_date"=> Date.new(2011,12,3)},
            "ts6" => {"host"=>"http://ts6.travian.pt/", "code"=>"ts6", "name"=>"Servidor6", "start_date"=> Date.new(2012,10,18)},
            "ts7" => {"host"=>"http://ts7.travian.pt/", "code"=>"ts7", "name"=>"Servidor7", "start_date"=> Date.new(2012,12,8)},
            "tx3" => {"host"=>"http://tx3.travian.pt/", "code"=>"tx3", "name"=>"Speed3x", "start_date"=> Date.new(2012,9,29)},
          }
        end

        after do
          Timecop.return
        end
      end
    end

    describe '.servers_hash' do
      include_context 'fake pt serverLogin'
      include_context 'fake portuguese hub and servers'

      before(:each) { @hub = double('Hub', :host => "http://www.travian.pt/") }

      it 'should return a Hash' do
        Server.send(:servers_hash, @hub).should be_a Hash
      end

      it 'should not contain classic servers' do
        servers = Server.send(:servers_hash, @hub)
        servers.keys.should_not include('tc9')
      end
    end

    describe '.parse_subdomain' do
      context 'when passed "http://ts4.travian.net/"' do
        it 'returns the subdomain "ts4" from the host' do
          Server.parse_subdomain('http://ts4.travian.net/').should == 'ts4'
        end
      end

      context 'when passed "http://tx3.travian.com.br/"' do
        it 'returns the subdomain "tx3" from the host' do
          Server.parse_subdomain('http://tx3.travian.com.br/').should == 'tx3'
        end
      end

      context 'when passed "http://arabiats6.travian.com/"' do
        it 'returns the subdomain "arabiats6" from the host' do
          Server.parse_subdomain('http://arabiats6.travian.com/').should == 'arabiats6'
        end
      end
    end

    describe '.parse_server_data' do
      include_context 'load sample server data'

      it 'should be a Hash' do
        Server.send(:parse_server_data, @server_data).should be_a Hash
      end

      it 'delegates parsing of worldId to .parse_world_id' do
        Server.should_receive(:parse_world_id).once
        Server.send(:parse_server_data, @server_data)
      end

      it 'delegates parsing of version to .parse_version' do
        Server.should_receive(:parse_version).once
        Server.send(:parse_server_data, @server_data)
      end

      it 'delegates parsing of speed to .parse_speed' do
        Server.should_receive(:parse_speed).once
        Server.send(:parse_server_data, @server_data)
      end
    end

    describe '.parse_hub_server_data' do
      include_context 'load sample hub server data'

      it 'delegates parsing of host to .parse_host' do
        Server.should_receive(:parse_host).with(@hub_server_data) { 'http://ts1.travian.pt/'}
        Server.send(:parse_hub_server_data, @hub_server_data)
      end

      it 'delegates parsing of name to .parse_name' do
        Server.should_receive(:parse_name).with(@hub_server_data)
        Server.send(:parse_hub_server_data, @hub_server_data)
      end

      it 'delegates parsing of start_date to .parse_start_date' do
        Server.should_receive(:parse_start_date).with(@hub_server_data)
        Server.send(:parse_hub_server_data, @hub_server_data)
      end
    end

    describe '.fetch_hub_server_data' do
      include_context 'fake pt serverLogin'

      before(:each) do
        @hub = double('Hub', :host => 'http://www.travian.pt/')
      end

      it 'should return a Nokogiri::XML::NodeSet object' do
        Server.send(:fetch_hub_server_data, @hub).should be_a Nokogiri::XML::NodeSet
      end

      it 'should contain 10 div[class~="server"]' do
        res = Server.send(:fetch_hub_server_data, @hub)
        res.search('div[class~="server"]').size.should be 10
      end
    end

    describe '.fetch_server_data' do
      include_context 'fake tx3.travian.pt'

      it 'should be a Nokogiri::XML::NodeSet' do
        Server.send(:fetch_server_data, 'http://tx3.travian.pt/')
      end
    end

    describe '.parse_host' do
      include_context 'load sample hub server data'
      it 'should return the server host' do
        Server.send(:parse_host, @hub_server_data).should == 'http://ts1.travian.pt/'
      end
    end

    describe '.parse_name' do
      include_context 'load sample hub server data'
      it 'should return the server name' do
        Server.send(:parse_name, @hub_server_data).should == 'Servidor1'
      end
    end

    describe '.parse_players' do
      include_context 'load sample hub server data'
      it "should return the server's number of players" do
        Server.send(:parse_players, @hub_server_data).should == 1393
      end
    end

    describe '.parse_start_date' do
      include_context 'load sample hub server data'
      it "should return the server's start date" do
        Server.send(:parse_start_date, @hub_server_data).should == Date.today - 331
      end
    end
  end
end
