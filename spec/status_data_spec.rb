require 'spec_helper'

module Travian
  describe StatusData do
    let(:data) { load_server_data 'status.travian.com' }

    describe '.parse' do
      subject { StatusData.parse(data) }

      it { should be_a Hash }

      it { should have(51).hubs }

      it { should have_key :pt }

      it { should have_key :in }

      it { should have_key :net }

      it { should have_key :asia }

      it { should_not have_key :th }

      it { should_not have_key :ine }

      it { should_not have_key :es }

      it { should_not have_key :gq }

    end

    describe '.parse_hub_codes' do
      it 'should be an Array' do
        StatusData.send(:parse_hub_codes, data).should be_an Array
      end

      it 'should have 52 codes' do
        StatusData.send(:parse_hub_codes, data).should have(52).codes
      end

      it 'should have no empty strings' do
        StatusData.send(:parse_hub_codes, data).all? {|code| !code.empty? }
      end
    end

    describe '.parse_server_hosts' do
      it 'should return an array of hosts' do
        StatusData.send(:parse_server_hosts, data, 'ae').should be_an Array
      end

      it 'should return 7 hosts when passed the hub_code "ae"' do
        StatusData.send(:parse_server_hosts, data, 'ae').should have(7).hosts
      end

      it 'should return an empty array when passed an invalid hub_code' do
        StatusData.send(:parse_server_hosts, data, 'fp').should have(0).hosts
      end
    end
  end
end
