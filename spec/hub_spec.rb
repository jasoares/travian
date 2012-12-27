require 'spec_helper'

class FakeHub
  include Travian::Hub
end

module Travian
  describe Hub do
    let(:hub) { FakeHub.new }

    describe '::CODES' do
      subject { Hub::CODES }

      it { should be_a Hash }

      it { should have_key 'pt' }

      it { should have_key :pt }
    end

    describe '.fetch_list!' do
      context 'given a hash with 2 hubs' do
        before(:each) do
          @hubs_hash = {
            com: { code: 'com', host: 'http://www.travian.com/', name: 'International', language: 'en' },
            pt:  { code:  'pt', host:  'http://www.travian.pt/', name:      'Portugal', language: 'pt' }
          }.with_indifferent_access
          Hub.stub(:hubs_hash => @hubs_hash)
        end

        subject { Hub.fetch_list! }

        its(:keys) { should == ['com', 'pt'] }

        its(:values) { should == @hubs_hash.values }

        it 'should delegate to .hubs_hash to get the data' do
          Hub.should_receive(:hubs_hash).with no_args
          Hub.fetch_list!
        end

        it { should be_a Hash }

        it { should have(2).hubs }

        context 'when passed a block' do
          it 'should yield each hub to the block' do
            expect {|b| Hub.fetch_list! &b }.to yield_successive_args(*@hubs_hash)
          end
        end
      end
    end

    describe '.name_of' do
      it "returns 'Portugal' when passed 'pt'" do
        Hub.send(:name_of, 'pt').should == 'Portugal'
      end
    end

    describe '.language_of' do
      it "returns 'es' when passed 'net'" do
        Hub.send(:language_of, 'net').should == 'es'
      end
    end

    describe '.hub_js_hash' do
      before(:each) do
        @js_hash = "{'key':'value'}"
        Hub.stub(:fetch_data => @js_hash)
      end

      subject { Hub.send(:hub_js_hash) }

      it { should be_a Hash }

      it { should have_key :key }

      it 'delegates data convertion to Hash.from_js' do
        Hash.should_receive(:from_js).with(@js_hash)
        Hub.send(:hub_js_hash)
      end

      it 'delegates to Hub.fetch_data to get the data' do
        Hub.should_receive(:fetch_data).with no_args
        Hub.send(:hub_js_hash)
      end
    end

    shared_examples '.fetch_data' do
      before(:all) { @hub = Hub.send(:fetch_data) }
      subject { @hub }

      it { should be_a String }

      it { should start_with "{container:'flags'" }

      it { should end_with "'http://www.travian.co.nz/'}}}" }

      it { should include "flags:{'europe':" }

      it { should_not include "(" }

      it { should_not include ")" }
    end

    describe '.fetch_data' do
      include_context 'fake main hub'
      include_examples '.fetch_data'
    end

    describe '.fetch_data', :online => true do
      include_context 'online'
      include_examples '.fetch_data'
    end
  end
end
