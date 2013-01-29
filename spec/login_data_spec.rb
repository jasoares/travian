require 'spec_helper'

module Travian
  describe LoginData do
    let(:klass) { LoginData }
    let(:pt_data) { load_servers_login_data('www.travian.pt') }
    let(:de_data) { load_servers_login_data('www.travian.de') }
    let(:arabia_data) { load_servers_login_data('arabia.travian.com') }

    let(:pt_tx3) { LoginData.new(pt_data[8]) }
    let(:de_tx3) { LoginData.new(de_data[6]) }
    let(:arabia_tx4) { LoginData.new(arabia_data[1]) }

    describe '#host' do
      it 'returns "http://tx3.travian.pt/" when called on tx3.travian.pt LoginData' do
        pt_tx3.host.should == "http://tx3.travian.pt/"
      end

      it 'returns "http://arabiatx4.travian.com/" when called on arabiatx4.travianc.com LoginData' do
        arabia_tx4.host.should == "http://arabiatx4.travian.com/"
      end
    end

    describe '#name' do
      it 'returns "Speed 3x" when called on tx3.travian.de LoginData' do
        de_tx3.name.should == "Speed 3x"
      end

      it 'returns "arabia 4x" when called on arabiatx4.travian.com LoginData' do
        arabia_tx4.name.should == "arabia 4x"
      end
    end

    describe '#players' do
      it 'returns 2039 when called on tx3.travian.pt LoginData' do
        pt_tx3.players.should == 3101
      end
    end

    describe '#start_date' do
      before(:all) do
        Timecop.freeze(Time.utc(2012,12,27,10,20,0))
      end

      it 'returns a DateTime object' do
        pt_tx3.start_date.should be_a DateTime
      end

      it 'returns "29/09/2012" when passed the tx3 server' do
        pt_tx3.start_date.should == Date.new(2012,9,3).to_datetime
      end

      after(:all) { Timecop.return }
    end

    describe '.split_servers' do
      it 'returns an array with 6 login data chunks when passed data from arabia.travian.com' do
        data = load_login_data('arabia.travian.com')
        klass.split_servers(data).should have(6).login_data_chunks
      end

      it 'returns an array with 10 login data chunks when passed data from www.travian.pt' do
        data = load_login_data('www.travian.pt')
        klass.split_servers(data).should have(10).login_data_chunks
      end

      it 'returns an array with 8 login data chunks when passed data from www.travian.de' do
        data = load_login_data('www.travian.de')
        klass.split_servers(data).should have(8).login_data_chunks
      end
    end
  end
end
