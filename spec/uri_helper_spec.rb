require 'spec_helper'

module Travian
  class UriHelperIncluder
    include UriHelper
  end

  describe UriHelper do
    let(:obj) { UriHelperIncluder.new }

    describe '#tld' do
      it 'returns "com" when uri is "http://www.travian.com/"' do
        obj.stub(host: 'http://www.travian.com/')
        obj.tld.should == 'com'
      end

      it 'returns "com" when uri is "http://www.travian.com"' do
        obj.stub(host: 'http://www.travian.com')
        obj.tld.should == 'com'
      end

      it 'returns "co.uk" when uri is "http://www.travian.co.uk"' do
        obj.stub(host: 'http://www.travian.co.uk')
        obj.tld.should == 'co.uk'
      end

      it 'returns "com.au" when uri is "http://www.travian.com.au/"' do
        obj.stub(host: 'http://www.travian.com.au/')
        obj.tld.should == 'com.au'
      end
    end

    describe '#subdomain' do
      it 'returns "www" when uri is "http://www.travian.co.kr"' do
        obj.stub(host: 'http://www.travian.co.kr')
        obj.subdomain.should == 'www'
      end

      it 'returns "ts1" when uri is "http://ts1.travian.pt/"' do
        obj.stub(host: 'http://ts1.travian.pt/')
        obj.subdomain.should == 'ts1'
      end

      it 'returns "tx3" when uri is "http://tx3.travian.pt/"' do
        obj.stub(host: 'http://tx3.travian.pt/')
        obj.subdomain.should == 'tx3'
      end

      it 'returns "arabiats4" when uri is "http://arabiats4.travian.com/"' do
        obj.stub(host: 'http://arabiats4.travian.com/')
        obj.subdomain.should == 'arabiats4'
      end
    end
  end
end