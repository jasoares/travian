require 'spec_helper'

module Travian
  describe LoginData do
    let(:klass) { LoginData }
    let(:pt_data) { load_servers_login_data('www.travian.pt') }
    let(:de_data) { load_servers_login_data('www.travian.de') }
    let(:arabia_data) { load_servers_login_data('arabia.travian.com') }

    let(:pt_tx3_data) { LoginData.new(pt_data[8]) }
    let(:de_tx3_data) { LoginData.new(de_data[6]) }
    let(:arabia_tx4_data) { LoginData.new(arabia_data[1]) }

    describe '.host' do
      it 'returns "http://tx3.travian.pt/" when passed server data' do
        pt_tx3_data.host.should == "http://tx3.travian.pt/"
      end
    end

    describe '.parse_name' do
      it 'returns "Speed 3x" when passed the tx3.travian.de server' do
        de_tx3_data.name.should == "Speed 3x"
      end

      it 'returns "arabia 4x" when passed the arabiatx4.travian.com server' do
        arabia_tx4_data.name.should == "arabia 4x"
      end
    end

    describe '.parse_players' do
      it 'returns 2039 when passed the tx3 server' do
        pt_tx3_data.players.should == 3101
      end
    end

    describe '.parse_start_date' do
      before(:all) do
        Timecop.freeze(Time.utc(2012,12,27,10,20,0))
      end

      it 'returns a DateTime object' do
        pt_tx3_data.start_date.should be_a DateTime
      end

      it 'returns "29/09/2012" when passed the tx3 server' do
        pt_tx3_data.start_date.should == Date.new(2012,9,3).to_datetime
      end

      after(:all) { Timecop.return }
    end

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
  end
end
