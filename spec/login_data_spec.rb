require 'spec_helper'

def load_login_data(hub_host)
  Nokogiri::HTML(File.read(fakeweb_page "#{hub_host}_serverLogin.php"))
end

def load_servers_login_data(hub_host)
  data = load_login_data(hub_host)
  servers_selector(data)
end

def servers_selector(data)
  data.css('div[class~="server"]')
end

module Travian
  describe LoginData do
    let(:klass) { LoginData }
    let(:pt_data) { load_servers_login_data('www.travian.pt') }
    let(:de_data) { load_servers_login_data('www.travian.de') }
    let(:arabia_data) { load_servers_login_data('arabia.travian.com') }

    describe '.split_servers' do
      it 'should return an array with 6 servers when passed data from arabia.travian.com' do
        data = load_login_data('arabia.travian.com')
        klass.split_servers(data).should have(6).servers
      end

      it 'should return an array with 10 servers when passed data from www.travian.pt' do
        data = load_login_data('www.travian.pt')
        klass.split_servers(data).should have(10).servers
      end

      it 'should return an array with 10 servers when passed data from www.travian.de' do
        data = load_login_data('www.travian.de')
        klass.split_servers(data).should have(8).servers
      end
    end

    describe '.parse' do
      it 'delegates name parsing to LoginData.parse_name' do
        klass.should_receive(:parse_name).with(pt_data.first)
        klass.parse(pt_data.first)
      end

      it 'delegates start date parsing to LoginData.parse_start_date' do
        klass.should_receive(:parse_start_date).with(pt_data.first)
        klass.parse(pt_data.first)
      end

      it 'delegates name parsing to LoginData.parse_players' do
        klass.should_receive(:parse_players).with(pt_data.first)
        klass.parse(pt_data.first)
      end
    end

    describe '.parse_host' do
      it 'returns "http://tx3.travian.pt/" when passed server data' do
        klass.parse_host(pt_data[8]).should == "http://tx3.travian.pt/"
      end
    end

    describe '.parse_code' do
      it 'returns "tcx8" when passed "http://tcx8.travian.de/"' do
        klass.parse_code("http://tcx8.travian.de/").should == "tcx8"
      end

      it 'returns "ts4" when passed "http://ts4.travian.net/"' do
        klass.parse_code('http://ts4.travian.net/').should == 'ts4'
      end

      it 'returns "tx3" when passed "http://tx3.travian.com.br/"' do
        klass.parse_code('http://tx3.travian.com.br/').should == 'tx3'
      end

      it 'returns "arabiats6" when passed "http://arabiats6.travian.com/"' do
        klass.parse_code('http://arabiats6.travian.com/').should == 'arabiats6'
      end
    end

    describe '.parse_name' do
      it 'returns "Speed 3x" when passed the tx3.travian.de server' do
        klass.parse_name(de_data[6]).should == "Speed 3x"
      end

      it 'returns "arabia 4x" when passed the arabiatx4.travian.com server' do
        klass.parse_name(arabia_data[1]).should == "arabia 4x"
      end
    end

    describe '.parse_players' do
      it 'returns 2039 when passed the tx3 server' do
        klass.parse_players(pt_data[8]).should == 3101
      end
    end

    describe '.parse_start_date' do
      before(:all) do
        Timecop.freeze(Time.utc(2012,12,27,10,20,0))
      end

      it 'returns a DateTime object' do
        klass.parse_start_date(pt_data.first).should be_a DateTime
      end

      it 'returns "29/09/2012" when passed the tx3 server' do
        klass.parse_start_date(pt_data[8]).should == Date.new(2012,9,3).to_datetime
      end

      after(:all) { Timecop.return }
    end
  end
end
