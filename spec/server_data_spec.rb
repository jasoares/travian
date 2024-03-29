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
    let(:de_tcx8) { load_server_data 'tcx8.travian.de' }
    let(:it_beta) { load_server_data 'beta.travian.it' }

    describe '.parse' do
      it 'returns an Array' do
        klass.parse(pt_tx3).should be_an Array
      end

      it 'returns ["4.0", "de44", 1, DateTime.new(2013,1,21,6,0,0,"+01:00"), "server=de4"] when passed ts4.travian.de data' do
        klass.parse(de_ts4).should == ["4.0", "de44", 1, DateTime.new(2013,1,21,6,0,0,"+01:00"), "de4"]
      end

      it 'should have four elements, version, world_id, speed, restart_date and server_id' do
        klass.parse(pt_tx3).should have(5).elements
      end

      it 'returns for a classic server' do
        klass.parse(de_tcx8).should == [nil, nil, 0, nil, nil]
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

      it 'returns the nil when passed data from a classic server' do
        klass.parse_world_id(de_tcx8).should == nil
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

      it 'returns the nil when passed data from a classic server' do
        klass.parse_speed(de_tcx8).should == 0
      end
    end

    describe '.parse_version' do
      it 'returns "4.0" when passed data from arabiatx4.travian.pt' do
        klass.parse_version(arabia_tx4).should == "4.0"
      end

      it 'returns the nil when passed data from a classic server' do
        klass.parse_version(de_tcx8).should == nil
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

      it 'returns the nil when passed data from a classic server' do
        klass.parse_restart_date(de_tcx8).should == nil
      end
    end

    describe '.parse_server_id' do
      it 'returns the "server=sy17" when passed data from arabiatx4.travian.com' do
        klass.parse_server_id(arabia_tx4).should == "sy17"
      end

      it 'returns the "server=de4" when passed data from ts4.travian.de' do
        klass.parse_server_id(de_ts4).should == "de4"
      end

      it 'returns the "server=ptx" when passed data from tx3.travian.pt' do
        klass.parse_server_id(pt_tx3).should == "ptx"
      end

      it 'returns the "server=ae6" when passed data from ts6.travian.ae' do
        klass.parse_server_id(ae_ts6).should == "ae6"
      end

      it 'returns the nil when passed data from tcx8.travian.de' do
        klass.parse_server_id(de_tcx8).should == nil
      end

      it 'returns supports the new side bar format' do
        klass.parse_server_id(it_beta).should == "it00"
      end
    end

    describe '.select_info' do
      let(:attributes) { %w{ version worldId speed } }

      context 'given the common site structure where there is only one script' do
        it 'returns the script tags content with the "Travian.Game.*" lines' do
          str = klass.send(:select_info, pt_tx3)
          attributes.each { |attr| str.should match(/Travian.Game.#{attr}/) }
        end

        it 'returns an empty string when passed invalid data' do
          klass.send(:select_info, ph_ts2).should be_empty
        end
      end

      context 'given the edge case of the beta.travian.it' do
        it 'returns the script tags content with the "Travian.Game.*" lines' do
          str = klass.send(:select_info, it_beta)
          attributes.each { |attr| str.should match(/Travian.Game.#{attr}/) }
        end
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

      it 'returns "25.01.13 12:00 -03:00" when passed "25.01.13 12:00 (Gmt -03:00)"' do
        klass.send(:sanitize_date_format, "25.01.13 12:00 (Gmt -03:00)").should == "25.01.13 12:00 -03:00"
      end
    end
  end
end
