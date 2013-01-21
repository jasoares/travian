require 'spec_helper'

module Travian
  describe '.MAIN_HUB' do
    subject { Travian::MAIN_HUB }

    it { should == 'http://www.travian.com/' }
  end

  describe '.hubs', online: true do
    before(:all) do
      @hubs = FakeWeb.allow { Travian.hubs }
      fake 'www.travian.com'
    end

    subject { @hubs }

    it { should be_a HubsHash }

    it { should have_key :pt }

    its(:size) { should be 55 }

    it 's values should be Hubs' do
      @hubs.values.all? {|v| v.should be_a Hub }
    end

    after(:all) { unfake }
  end
end
