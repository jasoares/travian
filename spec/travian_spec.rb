require 'spec_helper'

module Travian
  describe '.MAIN_HUB' do
    subject { Travian::MAIN_HUB }

    it { should == 'http://www.travian.com/' }
  end

  describe '.hubs' do
    before(:all) { fake 'www.travian.com' }

    let(:hubs) { Travian.hubs }

    subject { hubs }

    it { should be_a HubsHash }

    it { should have_key :pt }

    its(:size) { should be 55 }

    it 'each value should be a Hub' do
      hubs.values.all? {|v| v.should be_a Hub }
    end

    context 'when no options are passed' do
      before(:each) do
        Travian.clear
      end

      it 'only fetches the hub list' do
        expect{ Travian.hubs }.not_to raise_exception
      end
    end

    context 'when passed :preload => :servers' do
      it 'fetches every hub servers list in advance' do
        Travian.hubs.each {|hub| hub.should_receive(:servers) }
        Travian.hubs(:preload => :servers)
      end
    end

    context 'when passed :preload => :mirrors' do
      it 'fetches every hub servers list and location in advance' do
        Travian.hubs.each {|hub| hub.should_receive(:mirrored_hub) }
        Travian.hubs(:preload => :mirrors)
      end
    end

    context 'when passed :preload => :all' do
      before(:each) do
        @server = double('Server', attributes: nil)
      end

      it 'fetches every hub location, servers and its attributes in advance' do
        Travian.hubs.each do |hub|
          hub.should_receive(:mirrored_hub)
          hub.should_receive(:servers).and_return([@server])
        end
        @server.should_receive(:attributes)
        Travian.hubs(:preload => :all)
      end
    end

    after(:all) { unfake }
  end
end
