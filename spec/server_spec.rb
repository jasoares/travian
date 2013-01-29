require 'spec_helper'

module Travian
  describe Server do
    context 'given the tx3.travian.pt server' do
      before(:all) do
        fake 'www.travian.com'
        fake 'www.travian.pt'
        fake 'www.travian.pt/serverLogin.php', :post
        fake 'tx3.travian.pt'
      end

      before(:each) do
        @hub = Hub.new(:pt, 'http://www.travian.pt/')
        @server = Travian.hubs[:pt].servers[:tx3]
        Timecop.freeze(Time.utc(2013,1,22))
      end

      subject { @server }

      its(:hub) { should == @hub }

      its(:host) { should == 'http://tx3.travian.pt/' }

      its(:code) { should == 'tx3' }

      its(:subdomain) { should == 'tx3' }

      its(:name) { should == 'Speed 3x' }

      its(:start_date) { should == Date.new(2012,9,29) }

      its(:start_date) { should be_a DateTime }

      its(:players) { should == 3101 }

      its(:world_id) { should == 'ptx18' }

      its(:speed) { should be 3 }

      its(:version) { should == "4.0" }

      describe '#attributes' do
        it 'should return a hash with the server\'s attributes' do
          @server.attributes.should == {
            host: 'http://tx3.travian.pt/',
            code: 'tx3',
            name: 'Speed 3x',
            world_id: 'ptx18',
            speed: 3,
          }
        end
      end

      describe '#classic?' do
        it 'returns true when called on a classic server like tcx8.travian.de' do
          server = Server.new(nil, nil, 'http://tcx8.travian.de/')
          server.should be_classic
        end

        it 'returns true when called on a classic server like tc27.travian.my' do
          server = Server.new(nil, nil, 'http://tc27.travian.my/')
          server.should be_classic
        end

        it 'returns false when called on a speed server like tx3.travian.com.br' do
          server = Server.new(nil, nil, 'http://tx3.travian.com.br/')
          server.should_not be_classic
        end

        it 'returns false when called on a normal server like ts4.travian.pt' do
          server = Server.new(nil, nil, 'http://ts4.travian.pt/')
          server.should_not be_classic
        end
      end

      after(:all) { unfake }
    end

    context 'given some active, restarting and ended servers' do
      before(:all) do
        fake 'www.travian.com'
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

      let(:in_hub) { Hub.new(:in, 'http://www.travian.in/') }
      let(:de_hub) { Hub.new(:de, 'http://www.travian.de/') }
      let(:in_restarting) { Server.new(in_hub, nil, 'http://ts3.travian.in/') }
      let(:de_restarting) { Server.new(de_hub, nil, 'http://ts4.travian.de/') }
      let(:de_running) { Travian.hubs[:de].servers[:ts5] }
      let(:de_running_built) { Server.new(de_hub, nil, 'http://ts5.travian.de/') }
      let(:de_ended) { Server.new(de_hub, nil, 'http://ts6.travian.de/') }

      describe '#restarting?' do
        it 'returns true when called on a restarting server' do
          de_restarting.should be_restarting
        end

        it 'returns true when called on another restarting server' do
          in_restarting.should be_restarting
        end

        it 'returns false when called on a running server' do
          de_running.should_not be_restarting
        end

        it 'return false when called on an ended server' do
          de_ended.should_not be_restarting
        end

        it 'returns false when called on a built running server' do
          de_running_built.should_not be_restarting
        end
      end

      describe '#ended?' do
        it 'returns true when called on an ended server' do
          de_ended.should be_ended
        end

        it 'returns true when called a restarting server' do
          de_restarting.should be_ended
        end

        it 'returns false when called on an active server' do
          de_running.should_not be_ended
        end

        it 'returns false when called on a built running server' do
          de_running_built.should_not be_ended
        end
      end

      describe '#running?' do
        it 'returns false when called on an ended server' do
          de_ended.should_not be_running
        end

        it 'returns false when called on a restarting server' do
          de_restarting.should_not be_running
        end

        it 'returns true when called on an active server' do
          de_running.should be_running
        end

        it 'returns true when called on a built running server' do
          de_running_built.should be_running
        end
      end

      describe '#start_date' do
        it 'returns the date the server started for an active server' do
          Timecop.freeze(Time.utc(2012,12,27,10,20,0))
          de_running.start_date.should == DateTime.new(2012, 11, 22)
          Timecop.return
        end

        it 'returns nil if the server ended' do
          de_ended.start_date.should be nil
        end
      end

      describe '#restart_date' do
        it 'returns nil when the server is running or has ended but there is still no restart date' do
          de_ended.restart_date.should be nil
        end

        it 'returns the restart date when the server has ended but there is already a restart date' do
          Timecop.freeze(Time.utc(2012,1,18))
          de_restarting.restart_date.should == DateTime.new(2013,1,21,6,0,0,"+01:00")
          Timecop.return
        end
      end

      after(:all) { unfake }
    end

    describe '.code' do
      let(:klass) { Server }
      it 'returns "tcx8" when passed "http://tcx8.travian.de/"' do
        klass.code("http://tcx8.travian.de/").should == "tcx8"
      end

      it 'returns "ts4" when passed "http://ts4.travian.net/"' do
        klass.code('http://ts4.travian.net/').should == 'ts4'
      end

      it 'returns "tx3" when passed "http://tx3.travian.com.br/"' do
        klass.code('http://tx3.travian.com.br/').should == 'tx3'
      end

      it 'returns "arabiats6" when passed "http://arabiats6.travian.com/"' do
        klass.code('http://arabiats6.travian.com/').should == 'arabiats6'
      end
    end

    describe '.[]' do
      before(:all) do
        fake 'www.travian.com'
        fake 'www.travian.pt'
        fake 'www.travian.pt/serverLogin.php', :post
      end

      it 'returns a Server object when passed a valid object' do
        server = double('Server', :code => 'tx3')
        server.stub_chain(:hub, :code).and_return('pt')
        Travian.hubs[:pt].servers.should_receive(:[]).with(:tx3).and_call_original
        Travian.hubs.should_receive(:[]).with(:pt).and_call_original
        Server[server]
      end

      it 'returns a Server object when passed the hub code and the server code' do
        Travian.hubs[:pt].servers.should_receive(:[]).with(:tx3).and_call_original
        Travian.hubs.should_receive(:[]).with(:pt).and_call_original
        Server[:pt, :tx3]
      end

      it 'returns nil when passed an invalid hub or an invalid server code' do
        Server[:pt, :tx4].should be nil
      end

      it 'raises ArgumentError when passed an invalid object like an integer' do
        expect { Server[3] }.to raise_error(ArgumentError)
      end

      it 'raises ArgumentError when passed invalid arguments like :pt, nil' do
        expect { Server[:pt, nil] }.to raise_error(ArgumentError)
      end
    end
  end
end
