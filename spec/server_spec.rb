require 'spec_helper'

module Travian
  describe Server do
    context 'given the tx3.travian.pt server' do
      before(:all) { fake 'tx3.travian.pt' }
      before(:each) do
        @hub = Hub.new(:pt, 'http://www.travian.pt/')
        @server = Server.new(@hub, 'http://tx3.travian.pt/', 'tx3', 'Speed3x', Date.new(2012,9,29).to_datetime, 3113)
      end

      subject { @server }

      its(:hub) { should == @hub }

      its(:host) { should == 'http://tx3.travian.pt/' }

      its(:code) { should == 'tx3' }

      its(:subdomain) { should == 'tx3' }

      its(:name) { should == 'Speed3x' }

      its(:start_date) { should == Date.new(2012,9,29) }

      its(:start_date) { should be_a DateTime }

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
            world_id: 'ptx18',
            speed: 3,
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
          server = Server.new(nil, 'http://tcx8.travian.de/', 'tcx8', 'Speed8x', Date.new(2012,12,11), 6911)
          server.classic?.should be true
        end

        it 'returns true when called on a classic server like tc27.travian.my' do
          server = Server.new(nil, 'http://tc27.travian.my/', 'tc27', 'Classic Server 27', Date.new(2012,12,11), 6911)
          server.classic?.should be true
        end

        it 'returns false when called on a speed server like tx3.travian.com.br' do
          server = Server.new(nil, 'http://tx3.travian.com.br/', 'tx3', 'Speed3x', Date.new(2012,12,11), 6911)
          server.classic?.should be false
        end

        it 'returns false when called on a normal server like ts4.travian.pt' do
          server = Server.new(nil, 'http://ts4.travian.pt/', 'ts4', 'Servidor 4', Date.new(2012,12,11), 6911)
          server.classic?.should be false
        end
      end

      after(:all) { unfake }
    end

    context 'given some active, restarting and ended servers' do
      before(:all) do
        fake 'www.travian.de'
        fake 'www.travian.de/serverLogin.php', :post
        fake 'ts4.travian.de'
        fake 'ts5.travian.de'
        fake 'ts6.travian.de'
        fake 'www.travian.in'
        fake 'www.travian.in/serverLogin.php', :post
        fake 'ts3.travian.in'
      end

      before(:each) do
        Timecop.freeze(Time.utc(2013,1,20,23,20,0))
      end

      let(:de_hub) { Hub.new(:de, 'http://www.travian.de/') }
      let(:in_hub) { Hub.new(:in, 'http://www.travian.in/') }
      let(:in_ts3) { Server.new(in_hub, 'http://ts3.travian.in/', :ts3, 'Server 3') }
      let(:de_ts4) { Server.new(de_hub, 'http://ts4.travian.de/', :ts4, 'Welt 4') }
      let(:de_ts5) { Server.new(de_hub, 'http://ts5.travian.de/', :ts5, 'Welt 5') }
      let(:de_ts6) { Server.new(de_hub, 'http://ts6.travian.de/', :ts6, 'Welt 6') }

      describe '#restarting?' do
        it 'returns true when called on a restarting server' do
          de_ts4.restarting?.should be true
        end

        it 'returns true when called on another restarting server' do
          in_ts3.restarting?.should be true
        end

        it 'returns false when called on a running server' do
          de_ts5.restarting?.should be false
        end

        it 'return false when called on an ended server' do
          de_ts6.restarting?.should be false
        end
      end

      describe '#ended?' do
        it 'returns true when called on an ended server' do
          de_ts6.ended?.should be true
        end

        it 'returns true when called a restarting server' do
          de_ts4.ended?.should be true
        end

        it 'returns false when called on an active server' do
          de_ts5.ended?.should be false
        end
      end

      describe '#running?' do
        it 'returns false when called on an ended server' do
          de_ts6.running?.should be false
        end

        it 'returns false when called on a restarting server' do
          de_ts4.running?.should be false
        end

        it 'returns true when called on an active server' do
          de_ts5.running?.should be true
        end
      end

      describe '#start_date' do
        it 'returns the announced time for a restarting server' do
          de_ts4.start_date.should == DateTime.new(2013, 1, 21, 6, 0, 0, "+01:00")
        end

        it 'returns the date the server started for an active server' do
          Timecop.freeze(Time.utc(2012,12,27,10,20,0))
          de_ts5.start_date.should == DateTime.new(2012, 11, 22)
          Timecop.return
        end

        it 'returns nil if the server ended and is not restarting' do
          de_ts6.start_date.should be nil
        end
      end

      describe '#parse_hub_page_start_date' do
        it 'returns the hub page computed start time' do
          Timecop.freeze(Time.utc(2012,12,27,10,20,0))
          de_ts5.send(:parse_hub_page_start_date).should == DateTime.new(2012,11,22)
          Timecop.return
        end
      end

      describe '#parse_restart_page_start_date' do
        it 'returns the restart time on the server restart page' do
          data = Nokogiri::HTML('<div id="worldStartInfo"><div class="countdownContent">    Rundenstart am <br/><span class="date">21.01.13 06:00<span class="timezone"> (Gmt +01:00)</span></span> </div></div>')
          de_ts4.send(:parse_restart_page_start_date, data).should == DateTime.new(2013,1,21,6,0,0,"+01:00")
        end

        it 'returns nil if the server has no restart page' do
          data = Nokogiri::HTML(de_ts6.send(:fetch_server_data))
          de_ts6.send(:parse_restart_page_start_date, data).should be nil
        end
      end

      after(:all) { unfake }
    end

    describe '.sanitize_date_format' do
      it 'returns "25.01.13 12:00 +05:30" when passed "25.01.13 12:00 (GMT +05:30).  "' do
        Server.sanitize_date_format("   25.01.13 12:00 (GMT +05:30).  ").should == "25.01.13 12:00 +05:30"
      end

      it 'returns "21.01.13 06:00 +01:00" when passed "21.01.13 06:00 (Gmt +01:00)"' do
        Server.sanitize_date_format("21.01.13 06:00 (Gmt +01:00)").should == "21.01.13 06:00 +01:00"
      end
    end

    describe '.fetch_server_data' do
      it 'raises Travian::ConnectionTimeout if server is offline' do
        hub = Hub.new(:br, 'http://www.travian.com.br/')
        server = Server.new(hub, 'http://tx3.travian.com.br/', 'tx3', 'Speed3x', Date.new(2012,12,11), 6911)
        expect { server.send :fetch_server_data }.to raise_error(
          Travian::ConnectionTimeout,
          %r{Error connecting to 'http://tx3.travian.com.br/' \(}
        )
      end
    end

    describe '.new' do
      context 'when passed a symbol code' do
        before(:all) { fake 'tx3.travian.pt' }
        before(:each) do
          hub = Hub.new(:pt, 'http://www.travian.pt/')
          @server = Server.new(hub, 'http://tx3.travian.pt/', :tx3, 'Speed3x', Date.new(2012,9,29), 3113)
        end

        subject { @server }

        its(:code) { should == 'tx3' }

        after(:all) { unfake }
      end
    end
  end
end
