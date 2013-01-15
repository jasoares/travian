require 'spec_helper'

module Travian
  describe ServersHash do
    context 'given the ServersHash built from the portuguese hub' do
      fake 'www.travian.pt/serverLogin.php', :post
      before(:each) do
        hub = double('Hub', :host => 'http://www.travian.pt/')
        @hash = ServersHash.build(hub)
      end

      subject  { @hash }

      it { should_not have_key :tc9 }

      it { should have(9).servers }

      it { should_not be_empty }

      its(:size) { should be 9 }

      its(:keys) { should === [:ts1, :ts10, :ts2, :ts3, :ts4, :ts5, :ts6, :ts7, :tx3] }
    end

    context 'given the ServersHash built from the german hub' do
      fake 'www.travian.de/serverLogin.php', :post
      before(:each) do
        hub = double('Hub', :host => 'http://www.travian.de/')
        @hash = ServersHash.build(hub)
      end

      subject  { @hash }

      it { should_not have_key :tcx8 }

      it { should have(7).servers }

      it { should_not be_empty }

      its(:size) { should be 7 }

      its(:keys) { should == [:ts1, :ts2, :ts3, :ts5, :ts7, :ts8, :tx3] }
    end

    context 'given the ServersHash built from the new zealand hub' do
      fake 'www.travian.co.nz/serverLogin.php', :post
      before(:each) do
        hub = double('Hub', host: 'http://www.travian.co.nz/')
        @hash = ServersHash.build(hub)
      end

      subject { @hash }

      it { should have(0).servers }

      its(:size) { should be 0 }

      it { should be_empty }
    end

    describe '.new' do
      it 'raises ArgumentError when passed an argument that is not a Hash' do
        expect { ServersHash.new(123) }.to raise_error(ArgumentError)
      end
    end

    shared_context 'when passed servers_data' do
      fake 'www.travian.pt/serverLogin.php', :post
      before(:each) do
        @hub = double('Hub', :host => 'http://www.travian.pt/')
        @servers_data = Nokogiri::HTML(ServersHash.fetch_servers(@hub.host))
        @server_data = ServersHash.send(:split_servers, @servers_data)[-2]
      end
    end

    describe '.build' do
      include_context 'when passed servers_data'

      it 'returns a Hash object' do
        ServersHash.build(@hub).should be_a ServersHash
      end

      it 'delegates the data splitting to ServersHash.select_servers' do
        ServersHash.should_receive(:split_servers).once.and_call_original
        ServersHash.build(@hub)
      end

      it 'delegates host parsing to ServersHash.parse_host' do
        ServersHash.should_receive(:parse_host).exactly(10).times.and_call_original
        ServersHash.build(@hub)
      end

      it 'delegates name parsing to ServersHash.parse_name' do
        ServersHash.should_receive(:parse_name).exactly(10).times.and_call_original
        ServersHash.build(@hub)
      end

      it 'delegates start date parsing to ServersHash.parse_start_date' do
        ServersHash.should_receive(:parse_start_date).exactly(10).times.and_call_original
        ServersHash.build(@hub)
      end

      it 'delegates name parsing to ServersHash.parse_players' do
        ServersHash.should_receive(:parse_players).exactly(10).times.and_call_original
        ServersHash.build(@hub)
      end

      it 'calls ServersHash.new to create the object to return' do
        ServersHash.should_receive(:new).with(kind_of(Hash)).once
        ServersHash.build(@hub)
      end
    end

    describe '.parse_host' do
      include_context 'when passed servers_data'

      it 'returns "http://tx3.travian.pt/" when passed server data' do
        ServersHash.parse_host(@server_data).should == "http://tx3.travian.pt/"
      end
    end

    describe '.parse_subdomain' do
      include_context 'when passed servers_data'

      it 'returns "tcx8" when passed "http://tcx8.travian.de/"' do
        ServersHash.parse_subdomain("http://tcx8.travian.de/").should == "tcx8"
      end

      it 'returns "ts4" when passed "http://ts4.travian.net/"' do
        ServersHash.parse_subdomain('http://ts4.travian.net/').should == 'ts4'
      end

      it 'returns "tx3" when passed "http://tx3.travian.com.br/"' do
        ServersHash.parse_subdomain('http://tx3.travian.com.br/').should == 'tx3'
      end

      it 'returns "arabiats6" when passed "http://arabiats6.travian.com/"' do
        ServersHash.parse_subdomain('http://arabiats6.travian.com/').should == 'arabiats6'
      end
    end

    describe '.parse_name' do
      include_context 'when passed servers_data'

      it 'returns "Speed3x" when passed the tx3 server' do
        ServersHash.parse_name(@server_data).should == "Speed3x"
      end
    end

    describe '.parse_start_date' do
      include_context 'when passed servers_data'
      before(:all) do
        Timecop.freeze(Time.utc(2012,12,27,10,20,0))
      end

      it 'returns "29/09/2012" when passed the tx3 server' do
        ServersHash.parse_start_date(@server_data).should == Date.new(2012,9,3)
      end

      after(:all) do
        Timecop.return
      end
    end

    describe '.parse_players' do
      include_context 'when passed servers_data'

      it 'returns 2039 when passed the tx3 server' do
        ServersHash.parse_players(@server_data).should == 3101
      end
    end
  end
end
