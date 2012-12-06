require 'spec_helper'

describe Hash do
  describe '.from_js' do
    context "given a js hash of {regions:{'europe':'Europe','america':'America'}}" do

      let(:hash) { Hash.from_js "{regions:{'europe':'Europe','america':'America'}}" }
      
      subject { hash }

      it { should be_a HashWithIndifferentAccess }

      it { should have_key :regions }

      it { should have_key 'regions' }

      it { should == {'regions' => { 'europe' => 'Europe', 'america' => 'America'} } }

    end
  end
end
