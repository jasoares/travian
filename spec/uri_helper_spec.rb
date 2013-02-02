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

      it 'returns "com" when uri is "ts1.travianteam.com"' do
        obj.stub(host: 'ts1.travianteam.com')
        obj.tld.should == 'com'
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

    describe '#hub_code' do
      it 'returns "kr" when uri is "http://www.travian.co.kr/"' do
        obj.stub(host: 'http://www.travian.co.kr/')
        obj.hub_code.should == "kr"
      end

      it 'returns "arabia" when uri is "http://arabia.travian.com"' do
        obj.stub(host: 'http://arabia.travian.com/')
        obj.hub_code.should == "arabia"
      end

      it 'returns "arabia" when uri is "http://arabiatcx3.travian.com"' do
        obj.stub(host: 'http://arabiatcx3.travian.com/')
        obj.hub_code.should == "arabia"
      end

      it 'returns "cn" when uri is "http://www.travian.cc/"' do
        obj.stub(host: 'http://www.travian.cc')
        obj.hub_code.should == 'cn'
      end
    end

    describe '#server_code' do
      it 'returns nil when uri is "http://www.travian.com/"' do
        obj.stub(host: 'http://www.travian.com/')
        obj.server_code.should == nil
      end

      it 'returns nil when uri is "http://arabia.travian.com/"' do
        obj.stub(host: 'http://arabia.travian.com/')
        obj.server_code.should == nil
      end

      it 'returns "tx3" when uri is "http://tx3.travian.com.br"' do
        obj.stub(host: 'http://tx3.travian.com.br/')
        obj.server_code.should == "tx3"
      end

      it 'returns "arabia" when uri is "http://arabiatcx3.travian.com"' do
        obj.stub(host: 'http://arabiatcx3.travian.com/')
        obj.server_code.should == "arabiatcx3"
      end

    end

    describe '.strip_protocol' do
      it 'returns "www.travian.com" when passed "http://www.travian.com/"' do
        UriHelper.strip_protocol('http://www.travian.com/').should == 'www.travian.com'
      end

      it 'returns "tx3.travianteam.co.kr" when passed "http://tx3.travianteam.co.kr/"' do
        UriHelper.strip_protocol('http://tx3.travianteam.co.kr/'). should == 'tx3.travianteam.co.kr'
      end

      it 'returns "tcx8.travian.com.au" when passed "http://tcx8.travian.com.au/"' do
        UriHelper.strip_protocol('http://tcx8.travian.com.au/').should == 'tcx8.travian.com.au'
      end

      it 'returns "tx3.travian.pt" when passed "http://tx3.travian.pt/' do
        UriHelper.strip_protocol('http://tx3.travian.pt/').should == 'tx3.travian.pt'
      end

      it 'returns "tx3.travian.pt" when passed "http://tx3.travian.pt' do
        UriHelper.strip_protocol('http://tx3.travian.pt').should == 'tx3.travian.pt'
      end

      it 'returns "tx3.travian.pt/serverLogin.php" when passed "http://tx3.travian.pt/serverLogin.php' do
        UriHelper.strip_protocol('http://tx3.travian.pt/serverLogin.php').should == 'tx3.travian.pt/serverLogin.php'
      end

    end

  end
end
