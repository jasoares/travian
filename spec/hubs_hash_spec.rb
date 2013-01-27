require 'spec_helper'

module Travian
  describe HubsHash do
    let(:klass) { HubsHash }

    it 'should extend HubsData' do
      klass.should respond_to :parse
    end

    it 'should extend Agent' do
      klass.should respond_to :hubs_data
    end

    describe '.build' do
      before(:all) { fake 'www.travian.com' }

      it 'delegates hubs data parsing to HubsData.parse' do
        klass.should_receive(:parse).and_return({})
        klass.build
      end

      it 'returns a HubsHash' do
        klass.build.should be_a HubsHash
      end

      after(:all) { unfake }
    end

    describe '#empty?' do
      it 'returns true if it contains no hubs' do
        klass.new({}).should be_empty
      end

      it 'returns false if it contains hubs' do
        hubs_hash = klass.new(pt: Hub.new(:pt, 'http://www.travian.pt/'), net: Hub.new(:net, 'http://www.travian.net'))
        hubs_hash.should_not be_empty
      end
    end
  end
end
