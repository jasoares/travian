require 'spec_helper'

module Travian
  describe LoginData do
    let(:klass) { LoginData }
    let(:pt_data) { load_servers_login_data('www.travian.pt') }
    let(:de_data) { load_servers_login_data('www.travian.de') }
    let(:arabia_data) { load_servers_login_data('arabia.travian.com') }
    let(:ir_data) { load_servers_login_data('www.travian.ir') }

    let(:pt_tx3) { pt_data[8] }
    let(:de_tx3) { de_data[6] }
    let(:arabia_tx4) { arabia_data[1] }
    let(:ir_ts1) { ir_data[0] }

    describe '.parse' do
      it 'returns a hash' do
        klass.parse(pt_data).should be_a Hash
      end

      it 'should have symbol keys' do
        klass.parse(pt_data).keys.all? {|k| k.should be_a Symbol }
      end

      it 'should call split_servers to split data by server' do
        klass.should_receive(:split_servers).with(pt_data).and_return([])
        klass.parse(pt_data)
      end

      it 'should call each of the parse methods for each element of split_servers returned array' do
        klass.should_receive(:split_servers).with(pt_data).and_return([pt_tx3, pt_tx3, pt_tx3])
        klass.should_receive(:parse_host).with(pt_tx3).exactly(3).times.and_return('tx3.travian.pt')
        klass.should_receive(:parse_name).with(pt_tx3).exactly(3).times.and_return('Speed 3x')
        klass.should_receive(:parse_start_date).with(pt_tx3).exactly(3).times.and_return(Date.new(2012,2,10,).to_datetime)
        klass.should_receive(:parse_players).with(pt_tx3).exactly(3).times.and_return(3101)
        klass.parse(pt_data)
      end

      it 'returns an inner hash with keys :host, :name, :start_date and :players' do
        klass.parse(pt_data).values.first.should have_key(:host)
        klass.parse(pt_data).values.first.should have_key(:name)
        klass.parse(pt_data).values.first.should have_key(:start_date)
        klass.parse(pt_data).values.first.should have_key(:players)
      end
    end

    describe '.parse_host' do
      it 'returns "tx3.travian.pt" when passed tx3.travian.pt login data' do
        klass.parse_host(pt_tx3).should == "tx3.travian.pt"
      end

      it 'returns "arabiatx4.travian.com" when passed arabiatx4.travianc.com login data' do
        klass.parse_host(arabia_tx4).should == "arabiatx4.travian.com"
      end
    end

    describe '.parse_name' do
      it 'returns "Speed 3x" when passed tx3.travian.de login data' do
        klass.parse_name(de_tx3).should == "Speed 3x"
      end

      it 'returns "arabia 4x" when passed arabiatx4.travian.com login data' do
        klass.parse_name(arabia_tx4).should == "arabia 4x"
      end
    end

    describe '.parse_players' do
      it 'returns 3101 when passed tx3.travian.pt login data' do
        klass.parse_players(pt_tx3).should == 3101
      end

      it 'returns 0 when passed the field is empty' do
        klass.parse_players(ir_ts1).should == 0
      end
    end

    describe '.parse_start_date' do
      before(:all) do
        Timecop.freeze(Time.utc(2012,12,27,10,20,0))
      end

      it 'returns a DateTime object' do
        klass.parse_start_date(pt_tx3).should be_a DateTime
      end

      it 'returns "29/09/2012" when passed the tx3 server' do
        klass.parse_start_date(pt_tx3).should == Date.new(2012,9,3).to_datetime
      end

      after(:all) { Timecop.return }
    end

    describe '.split_servers' do
      it 'returns an array with 6 login data chunks when passed data from arabia.travian.com' do
        klass.split_servers(arabia_data).should have(6).login_data_chunks
      end

      it 'returns an array with 10 login data chunks when passed data from www.travian.pt' do
        klass.split_servers(pt_data).should have(10).login_data_chunks
      end

      it 'returns an array with 8 login data chunks when passed data from www.travian.de' do
        klass.split_servers(de_data).should have(8).login_data_chunks
      end
    end
  end
end
