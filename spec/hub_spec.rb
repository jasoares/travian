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

    describe '.raw_hubs_hash' do
      before(:each) do
        @js_hash = "{flags:{'europe':{'ba':'http://www.travian.ba/'}}}"
        Hub.stub(:fetch_data => @js_hash)
      end

      subject { Hub.send(:raw_hubs_hash) }

      it { should be_a Hash }

      it { should have_key :ba }

      it 'delegates data convertion to Hash.from_js' do
        Hash.should_receive(:from_js).with(@js_hash).and_return(flags: {europe: {ba: 'http://www.travian.ba/'}})
        Hub.send(:raw_hubs_hash)
      end

      it 'delegates to Hub.fetch_data to get the data' do
        Hub.should_receive(:fetch_data).with no_args
        Hub.send(:raw_hubs_hash)
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
      context 'offline specs' do
        include_context 'fake main hub'
        include_examples '.fetch_data'
      end

      context 'online specs', online: true do
        include_context 'online'
        include_examples '.fetch_data'
      end
    end

    describe '.hubs_hash' do
      context 'given a hash with 2 hubs' do
        include_context 'fake main hub'
        include_context 'fake portuguese hub and servers'
        include_context 'fake czech hub and servers'

        before(:each) do
          @hubs = { ba: 'http://www.travian.cz/', bg: 'http://www.travian.pt/' }
        end

        it 'delegates data fetching to .raw_hubs_hash' do
          Hub.should_receive(:raw_hubs_hash) { @hubs }
          Hub.send(:hubs_hash)
        end

        it 'delegates redirection check to .redirected?' do
          Hub.should_receive(:is_mirror?).exactly(55).times
          Hub.send(:hubs_hash)
        end
      end
    end

    describe '.is_mirror?' do
      before(:all) do
        @host = 'http://www.travian.co.kr/'
      end

      it 'makes a post request to host/serverLogin.php with redirection limit set to 1' do
        HTTParty.should_receive(:post).with("#{@host}serverLogin.php", limit: 1)
        Hub.send(:is_mirror?, @host)
      end

      context 'when passed a host that redirects', online: true do
        include_context 'online'

        it 'returns true' do
          Hub.send(:is_mirror?, @host).should == true
        end
      end
    end
  end
end
