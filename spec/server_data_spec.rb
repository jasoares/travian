require 'spec_helper'

module Travian
  describe ServerData do
    before(:all) do
      fake 'tx3.travian.pt'
      fake 'ts4.travian.de'
    end

    let(:klass) { ServerData }
    let(:pt_tx3_server_data) { ServerData.new(double('Server', host: 'http://tx3.travian.pt/')) }
    let(:de_ts4_server_data) { ServerData.new(double('Server', host: 'http://ts4.travian.de/')) }

    describe '#restart_date' do
      it 'returns the restart time on the server restart page' do
        de_ts4_server_data.restart_date.should == DateTime.new(2013,1,21,6,0,0,"+01:00")
      end

      it 'returns nil if the server has no restart page' do
        pt_tx3_server_data.restart_date.should be nil
      end
    end

    describe '.sanitize_date_format' do
      it 'returns "25.01.13 12:00 +05:30" when passed "25.01.13 12:00 (GMT +05:30).  "' do
        klass.sanitize_date_format("   25.01.13 12:00 (GMT +05:30).  ").should == "25.01.13 12:00 +05:30"
      end

      it 'returns "21.01.13 06:00 +01:00" when passed "21.01.13 06:00 (Gmt +01:00)"' do
        klass.sanitize_date_format("21.01.13 06:00 (Gmt +01:00)").should == "21.01.13 06:00 +01:00"
      end
    end

    after(:all) { unfake }
  end
end
