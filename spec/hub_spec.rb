require 'spec_helper'

module Travian
  describe Hub do
    describe '::CODES' do
      subject { Hub::CODES }

      it { should be_a Hash }

      it { should have_key 'pt' }

      it { should have_key :pt }

      it 'should contain all travian hub codes' do
        (Hub.list.keys - Hub::CODES.keys).should == []
      end
    end

    describe '.list' do
      it 'should return a hash' do
        Hub.list.should be_a Hash
      end

      it 'should have 55 hubs' do
        Hub.list.should have(55).hubs
      end

      it 'should have the key :pt' do
        Hub.list.should have_key(:pt)
      end

      it 'should have the key :com' do
        Hub.list.should have_key(:com)
      end

      it "should have the value {:host => 'http://www.travian.com/', :name => 'International'}" do
        Hub.list.values.should include({'code' => 'com', 'host' => 'http://www.travian.com/', 'name' => 'International'})
      end
    end

    describe '.name_of' do
      it "returns 'Portugal' when passed 'pt'" do
        Hub.name_of('pt').should == 'Portugal'
      end
    end

    describe '.language_of' do
      it "returns 'es' when passed 'net'" do
        Hub.language_of('net').should == 'es'
      end
    end

    describe '.hub_js_hash' do
      it 'returns a hash' do
        Hub.send(:hub_js_hash).should be_a Hash
      end

      it 'should have a :flags key' do
        Hub.send(:hub_js_hash).should have_key(:flags)
      end

      it 'should have a :currentTld' do
        Hub.send(:hub_js_hash).should have_key(:currentTld)
      end
    end
  end
end