#encoding: utf-8
require 'spec_helper'

module Travian
  describe ServerData do
    let(:klass) { ServerData }
    let(:pt_tx3) { load_server_data 'tx3.travian.pt' }
    let(:ph_ts2) { load_server_data 'ts2.travian.ph' }
    let(:de_ts4) { load_server_data 'ts4.travian.de' }
    let(:arabia_tx4) { load_server_data 'arabiatx4.travian.com' }
    let(:ae_ts6) { load_server_data 'ts6.travian.ae' }

    describe '.parse' do
      it 'returns an Array' do
        klass.parse(pt_tx3).should be_an Array
      end

      it 'should have four elements, version, world_id, speed, and restart_date' do
        klass.parse(pt_tx3).should have(4).elements
      end
    end

    describe '.parse_world_id' do
      it 'returns "ptx18" when passed data from tx3.travian.pt' do
        klass.parse_world_id(pt_tx3).should == "ptx18"
      end

      it 'returns "de44" when passed data from ts4.travian.de' do
        klass.parse_world_id(de_ts4).should == "de44"
      end

      it 'returns "sy1717" when passed data from arabiatx4.travian.com' do
        klass.parse_world_id(arabia_tx4).should == "sy1717"
      end
    end

    describe '.parse_speed' do
      it 'returns 3 when passed data from tx3.travian.pt' do
        klass.parse_speed(pt_tx3).should be 3
      end

      it 'returns 1 when passed data from ts4.travian.de' do
        klass.parse_speed(de_ts4).should be 1
      end

      it 'returns 4 when passed data from arabiatx4.travian.com' do
        klass.parse_speed(arabia_tx4).should be 4
      end
    end

    describe '.parse_version' do
      it 'returns "4.0" when passed data from arabiatx4.travian.pt' do
        klass.parse_version(arabia_tx4).should == "4.0"
      end
    end

    describe '.parse_restart_date' do
      it 'returns the restart time on the server restart page' do
        klass.parse_restart_date(de_ts4).should == DateTime.new(2013,1,21,6,0,0,"+01:00")
      end

      it 'returns nil if the server has no restart page' do
        klass.parse_restart_date(pt_tx3).should be nil
      end

      it 'returns the restart time on the server restart page' do
        klass.parse_restart_date(ae_ts6).should == DateTime.new(2013,2,4,7,0,0,"+02:00")
      end
    end

    describe '.select_info' do
      it 'returns the script string when passed valid data' do
        klass.send(:select_info, pt_tx3).should_not be_empty
      end

      it 'returns an empty string when passed invalid data' do
        klass.send(:select_info, ph_ts2).should be_empty
      end
    end

    describe '.sanitize_date_format' do
      it 'returns "25.01.13 12:00 +05:30" when passed "25.01.13 12:00 (GMT +05:30).  "' do
        klass.send(:sanitize_date_format, "   25.01.13 12:00 (GMT +05:30).  ").should == "25.01.13 12:00 +05:30"
      end

      it 'returns "21.01.13 06:00 +01:00" when passed "21.01.13 06:00 (Gmt +01:00)"' do
        klass.send(:sanitize_date_format, "21.01.13 06:00 (Gmt +01:00)").should == "21.01.13 06:00 +01:00"
      end

      it 'returns "04.02.13 07:00 +02:00" when passed "04.02.13 07:00 (توقيت غرينتش +02:00)"' do
        klass.send(:sanitize_date_format, "04.02.13 07:00 (توقيت غرينتش +02:00)").should == "04.02.13 07:00 +02:00"
      end
    end
  end
end
