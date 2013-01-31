#encoding: utf-8
require 'spec_helper'

module Travian
  describe ServerData do
    let(:klass) { ServerData }
    let(:pt_tx3) { ServerData.new(load_server_data 'tx3.travian.pt') }
    let(:de_ts4) { ServerData.new(load_server_data 'ts4.travian.de') }
    let(:arabia_tx4) { ServerData.new(load_server_data 'arabiatx4.travian.com') }
    let(:ae_ts6) { ServerData.new(load_server_data 'ts6.travian.ae') }

    describe '#world_id' do
      it 'returns "ptx18" when called on tx3.travian.pt' do
        pt_tx3.world_id.should == "ptx18"
      end

      it 'returns "de44" when called on ts4.travian.de' do
        de_ts4.world_id.should == "de44"
      end

      it 'returns "sy1717" when called on arabiatx4.travian.com' do
        arabia_tx4.world_id.should == "sy1717"
      end
    end

    describe '#speed' do
      it 'returns 3 when called on tx3.travian.pt' do
        pt_tx3.speed.should be 3
      end

      it 'returns 1 when called on ts4.travian.de' do
        de_ts4.speed.should be 1
      end

      it 'returns 4 when called on arabiatx4.travian.com' do
        arabia_tx4.speed.should be 4
      end
    end

    describe '#version' do
      it 'returns "4.0" when called on arabiatx4.travian.pt' do
        arabia_tx4.version.should == "4.0"
      end
    end

    describe '#restart_date' do
      it 'returns the restart time on the server restart page' do
        de_ts4.restart_date.should == DateTime.new(2013,1,21,6,0,0,"+01:00")
      end

      it 'returns nil if the server has no restart page' do
        pt_tx3.restart_date.should be nil
      end

      it 'returns the restart time on the server restart page' do
        ae_ts6.restart_date.should == DateTime.new(2013,2,4,7,0,0,"+02:00")
      end
    end

    describe '.sanitize_date_format' do
      it 'returns "25.01.13 12:00 +05:30" when passed "25.01.13 12:00 (GMT +05:30).  "' do
        klass.sanitize_date_format("   25.01.13 12:00 (GMT +05:30).  ").should == "25.01.13 12:00 +05:30"
      end

      it 'returns "21.01.13 06:00 +01:00" when passed "21.01.13 06:00 (Gmt +01:00)"' do
        klass.sanitize_date_format("21.01.13 06:00 (Gmt +01:00)").should == "21.01.13 06:00 +01:00"
      end

      it 'returns "04.02.13 07:00 +02:00" when passed "04.02.13 07:00 (توقيت غرينتش +02:00)"' do
        klass.sanitize_date_format("04.02.13 07:00 (توقيت غرينتش +02:00)").should == "04.02.13 07:00 +02:00"
      end
    end

    after(:all) { unfake }
  end
end
