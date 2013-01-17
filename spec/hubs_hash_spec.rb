require 'spec_helper'

module Travian
  describe HubsHash do
    let(:hubs_hash) { HubsHash.new(pt: Hub.new(:pt, 'http://www.travian.pt/'), net: Hub.new(:net, 'http://www.travian.net')) }

    describe '.build' do
      fake 'www.travian.com'

      it 'returns a HubsHash' do
        HubsHash.build('http://www.travian.com/').should be_a HubsHash
      end
    end

    describe '.js_hash_to_ruby_hash' do
      context "given a js hash of {regions:{'europe':'Europe','america':'America'}}" do

        let(:hash) { HubsHash.js_hash_to_ruby_hash "{regions:{'europe':'Europe','america':'America'}}" }
        
        subject { hash }

        it { should be_a Hash }

        it { should have_key :regions }

        it { should == {:regions => { :europe => 'Europe', :america => 'America'} } }

      end
    end

    describe '.select' do
      fake 'www.travian.com'
      it 'should return the js hash' do
        data = Nokogiri::HTML(HubsHash.fetch_hub_data)
        HubsHash.select(data).should == "{container:'flags',currentTld:'com',adCode:'',regions:{'europe':'Europe','america':'America','asia':'Asia','middleEast':'Middle East','africa':'Africa','oceania':'Oceania'},flags:{'europe':{'ba':'http://www.travian.ba/','bg':'http://www.travian.bg/','com':'http://www.travian.com/','cz':'http://www.travian.cz/','de':'http://www.travian.de/','dk':'http://www.travian.dk/','fi':'http://www.travian.fi/','fr':'http://www.travian.fr/','gr':'http://www.travian.gr/','hr':'http://www.travian.com.hr/','hu':'http://www.travian.hu/','il':'http://www.travian.co.il/','it':'http://www.travian.it/','lt':'http://www.travian.lt/','net':'http://www.travian.net/','nl':'http://www.travian.nl/','no':'http://www.travian.no/','pl':'http://www.travian.pl/','pt':'http://www.travian.pt/','ro':'http://www.travian.ro/','rs':'http://www.travian.rs/','ru':'http://www.travian.ru/','se':'http://www.travian.se/','si':'http://www.travian.si/','sk':'http://www.travian.sk/','tr':'http://www.travian.com.tr/','ua':'http://www.travian.com.ua/','uk':'http://www.travian.co.uk/','ee':'http://www.travian.co.ee/','lv':'http://www.travian.lv/'},'america':{'ar':'http://www.travian.com.ar/','br':'http://www.travian.com.br/','cl':'http://www.travian.cl/','mx':'http://www.travian.com.mx/','us':'http://www.travian.us/'},'asia':{'cn':'http://www.travian.cc/','com':'http://www.travian.com/','hk':'http://www.travian.hk/','in':'http://www.travian.in/','id':'http://www.travian.co.id/','jp':'http://www.travian.jp/','my':'http://www.travian.com.my/','ph':'http://www.travian.ph/','kr':'http://www.travian.co.kr/','asia':'http://www.travian.asia/','vn':'http://www.travian.com.vn/','pk':'http://www.travian.pk/'},'middleEast':{'ae':'http://www.travian.ae/','ir':'http://www.travian.ir/','eg':'http://www.travian.com.eg/','arabia':'http://arabia.travian.com/','sa':'http://www.travian.com.sa/','ma':'http://www.travian.ma/'},'africa':{'za':'http://www.travian.co.za/','ma':'http://www.travian.ma/','eg':'http://www.travian.com.eg/'},'oceania':{'au':'http://www.travian.com.au/','nz':'http://www.travian.co.nz/'}}}"
      end
    end

    describe 'fetch_hub_data' do
      it 'raises an exception if MAIN_HUB is offline' do
        expect { HubsHash.fetch_hub_data }.to raise_error(Travian::ConnectionTimeout)
      end
    end

    describe '#empty?' do
      it 'returns true if it contains no hubs' do
        HubsHash.new({}).should be_empty
      end

      it 'returns false if it contains hubs' do
        hubs_hash.should_not be_empty
      end
    end
  end
end
