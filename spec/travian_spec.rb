require 'spec_helper'

module Travian
  describe '.MAIN_HUB' do
    subject { Travian::MAIN_HUB }

    it { should == 'http://www.travian.com/' }
  end

  describe '.hubs', online: true do
    fake 'www.travian.com'
    before(:all) do
      @hubs = FakeWeb.allow { Travian.hubs }
    end

    subject { @hubs }

    it { should be_a HubsHash }

    it { should have_key :pt }

    its(:size) { should be 54 }

    it 's values should be Hubs' do
      @hubs.values.all? {|v| v.is_a? Hub }
    end
  end
end
