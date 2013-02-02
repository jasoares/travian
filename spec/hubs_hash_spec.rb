require 'spec_helper'

module Travian
  describe HubsHash do
    let(:klass) { HubsHash }
    let(:data) { load_server_data 'www.travian.com' }
    let(:hubs_data) { HubsData.parse(data) }

    describe '.build' do
      it 'returns a HubsHash' do
        klass.build(hubs_data).should be_a HubsHash
      end

      it 'calls Hub.new for every hub' do
        Hub.should_receive(:new).exactly(55).times
        klass.build(hubs_data)
      end

      it 'passes the hub code and the hub host to every call to Hub.new' do
        Hub.should_receive(:new).with(:ba, 'www.travian.ba')
        klass.build([hubs_data.first])
      end
    end

    describe '#empty?' do
      it 'returns true if it contains no hubs' do
        klass.new({}).should be_empty
      end

      it 'returns false if it contains hubs' do
        hubs_hash = klass.new(pt: Hub.new(:pt, 'www.travian.pt'), net: Hub.new(:net, 'http://www.travian.net'))
        hubs_hash.should_not be_empty
      end
    end
  end
end
