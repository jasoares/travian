require 'spec_helper'

module Travian
  describe HubsData do
    let(:parser) { HubsData }

    describe '.parse' do
      it 'should parse hubs data to a hash of hubs' do
        data = Nokogiri::HTML(File.read(fakeweb_page 'www.travian.com'))
        parser.parse(data).should == {:ba=>"www.travian.ba", :bg=>"www.travian.bg", :com=>"www.travian.com", :cz=>"www.travian.cz", :de=>"www.travian.de", :dk=>"www.travian.dk", :fi=>"www.travian.fi", :fr=>"www.travian.fr", :gr=>"www.travian.gr", :hr=>"www.travian.com.hr", :hu=>"www.travian.hu", :il=>"www.travian.co.il", :it=>"www.travian.it", :lt=>"www.travian.lt", :net=>"www.travian.net", :nl=>"www.travian.nl", :no=>"www.travian.no", :pl=>"www.travian.pl", :pt=>"www.travian.pt", :ro=>"www.travian.ro", :rs=>"www.travian.rs", :ru=>"www.travian.ru", :se=>"www.travian.se", :si=>"www.travian.si", :sk=>"www.travian.sk", :tr=>"www.travian.com.tr", :ua=>"www.travian.com.ua", :uk=>"www.travian.co.uk", :ee=>"www.travian.co.ee", :lv=>"www.travian.lv", :ar=>"www.travian.com.ar", :br=>"www.travian.com.br", :cl=>"www.travian.cl", :mx=>"www.travian.com.mx", :us=>"www.travian.us", :cn=>"www.travian.cc", :hk=>"www.travian.hk", :in=>"www.travian.in", :id=>"www.travian.co.id", :jp=>"www.travian.jp", :my=>"www.travian.com.my", :ph=>"www.travian.ph", :kr=>"www.travian.co.kr", :asia=>"www.travian.asia", :vn=>"www.travian.com.vn", :pk=>"www.travian.pk", :ae=>"www.travian.ae", :ir=>"www.travian.ir", :eg=>"www.travian.com.eg", :arabia=>"arabia.travian.com", :sa=>"www.travian.com.sa", :ma=>"www.travian.ma", :za=>"www.travian.co.za", :au=>"www.travian.com.au", :nz=>"www.travian.co.nz"}
      end
    end

    describe '.parse_hubs_js_hash' do
      it 'should return the js hash' do
        data = Nokogiri::HTML(File.read(fakeweb_page 'www.travian.com'))
        parser.send(:parse_hubs_js_hash, data).should == "{container:'flags',currentTld:'com',adCode:'',regions:{'europe':'Europe','america':'America','asia':'Asia','middleEast':'Middle East','africa':'Africa','oceania':'Oceania'},flags:{'europe':{'ba':'http://www.travian.ba/','bg':'http://www.travian.bg/','com':'http://www.travian.com/','cz':'http://www.travian.cz/','de':'http://www.travian.de/','dk':'http://www.travian.dk/','fi':'http://www.travian.fi/','fr':'http://www.travian.fr/','gr':'http://www.travian.gr/','hr':'http://www.travian.com.hr/','hu':'http://www.travian.hu/','il':'http://www.travian.co.il/','it':'http://www.travian.it/','lt':'http://www.travian.lt/','net':'http://www.travian.net/','nl':'http://www.travian.nl/','no':'http://www.travian.no/','pl':'http://www.travian.pl/','pt':'http://www.travian.pt/','ro':'http://www.travian.ro/','rs':'http://www.travian.rs/','ru':'http://www.travian.ru/','se':'http://www.travian.se/','si':'http://www.travian.si/','sk':'http://www.travian.sk/','tr':'http://www.travian.com.tr/','ua':'http://www.travian.com.ua/','uk':'http://www.travian.co.uk/','ee':'http://www.travian.co.ee/','lv':'http://www.travian.lv/'},'america':{'ar':'http://www.travian.com.ar/','br':'http://www.travian.com.br/','cl':'http://www.travian.cl/','mx':'http://www.travian.com.mx/','us':'http://www.travian.us/'},'asia':{'cn':'http://www.travian.cc/','com':'http://www.travian.com/','hk':'http://www.travian.hk/','in':'http://www.travian.in/','id':'http://www.travian.co.id/','jp':'http://www.travian.jp/','my':'http://www.travian.com.my/','ph':'http://www.travian.ph/','kr':'http://www.travian.co.kr/','asia':'http://www.travian.asia/','vn':'http://www.travian.com.vn/','pk':'http://www.travian.pk/'},'middleEast':{'ae':'http://www.travian.ae/','ir':'http://www.travian.ir/','eg':'http://www.travian.com.eg/','arabia':'http://arabia.travian.com/','sa':'http://www.travian.com.sa/','ma':'http://www.travian.ma/'},'africa':{'za':'http://www.travian.co.za/','ma':'http://www.travian.ma/','eg':'http://www.travian.com.eg/'},'oceania':{'au':'http://www.travian.com.au/','nz':'http://www.travian.co.nz/'}}}"
      end
    end

    describe '.js_hash_to_ruby_hash' do
      context "given a js hash of {regions:{'europe':'Europe','america':'America'}}" do
        let(:hash) { parser.send(:js_hash_to_ruby_hash, "{regions:{'europe':'Europe','america':'America'}}") }
        
        subject { hash }

        it { should be_a Hash }

        it { should have_key :regions }

        it { should == {:regions => { :europe => 'Europe', :america => 'America'} } }

      end
    end

    describe '.flat_nested_hash' do
      it 'should return the hubs hash' do
        data = {:container=>"flags", :currentTld=>"com", :adCode=>"", :regions=>{:europe=>"Europe", :america=>"America", :asia=>"Asia", :middleEast=>"Middle East", :africa=>"Africa", :oceania=>"Oceania"}, :flags=>{:europe=>{:ba=>"http://www.travian.ba/", :bg=>"http://www.travian.bg/", :com=>"http://www.travian.com/", :cz=>"http://www.travian.cz/", :de=>"http://www.travian.de/", :dk=>"http://www.travian.dk/", :fi=>"http://www.travian.fi/", :fr=>"http://www.travian.fr/", :gr=>"http://www.travian.gr/", :hr=>"http://www.travian.com.hr/", :hu=>"http://www.travian.hu/", :il=>"http://www.travian.co.il/", :it=>"http://www.travian.it/", :lt=>"http://www.travian.lt/", :net=>"http://www.travian.net/", :nl=>"http://www.travian.nl/", :no=>"http://www.travian.no/", :pl=>"http://www.travian.pl/", :pt=>"http://www.travian.pt/", :ro=>"http://www.travian.ro/", :rs=>"http://www.travian.rs/", :ru=>"http://www.travian.ru/", :se=>"http://www.travian.se/", :si=>"http://www.travian.si/", :sk=>"http://www.travian.sk/", :tr=>"http://www.travian.com.tr/", :ua=>"http://www.travian.com.ua/", :uk=>"http://www.travian.co.uk/", :ee=>"http://www.travian.co.ee/", :lv=>"http://www.travian.lv/"}, :america=>{:ar=>"http://www.travian.com.ar/", :br=>"http://www.travian.com.br/", :cl=>"http://www.travian.cl/", :mx=>"http://www.travian.com.mx/", :us=>"http://www.travian.us/"}, :asia=>{:cn=>"http://www.travian.cc/", :com=>"http://www.travian.com/", :hk=>"http://www.travian.hk/", :in=>"http://www.travian.in/", :id=>"http://www.travian.co.id/", :jp=>"http://www.travian.jp/", :my=>"http://www.travian.com.my/", :ph=>"http://www.travian.ph/", :kr=>"http://www.travian.co.kr/", :asia=>"http://www.travian.asia/", :vn=>"http://www.travian.com.vn/", :pk=>"http://www.travian.pk/"}, :middleEast=>{:ae=>"http://www.travian.ae/", :ir=>"http://www.travian.ir/", :eg=>"http://www.travian.com.eg/", :arabia=>"http://arabia.travian.com/", :sa=>"http://www.travian.com.sa/", :ma=>"http://www.travian.ma/"}, :africa=>{:za=>"http://www.travian.co.za/", :ma=>"http://www.travian.ma/", :eg=>"http://www.travian.com.eg/"}, :oceania=>{:au=>"http://www.travian.com.au/", :nz=>"http://www.travian.co.nz/"}}}
        parser.send(:flat_nested_hash, data).should == {:ba=>"http://www.travian.ba/", :bg=>"http://www.travian.bg/", :com=>"http://www.travian.com/", :cz=>"http://www.travian.cz/", :de=>"http://www.travian.de/", :dk=>"http://www.travian.dk/", :fi=>"http://www.travian.fi/", :fr=>"http://www.travian.fr/", :gr=>"http://www.travian.gr/", :hr=>"http://www.travian.com.hr/", :hu=>"http://www.travian.hu/", :il=>"http://www.travian.co.il/", :it=>"http://www.travian.it/", :lt=>"http://www.travian.lt/", :net=>"http://www.travian.net/", :nl=>"http://www.travian.nl/", :no=>"http://www.travian.no/", :pl=>"http://www.travian.pl/", :pt=>"http://www.travian.pt/", :ro=>"http://www.travian.ro/", :rs=>"http://www.travian.rs/", :ru=>"http://www.travian.ru/", :se=>"http://www.travian.se/", :si=>"http://www.travian.si/", :sk=>"http://www.travian.sk/", :tr=>"http://www.travian.com.tr/", :ua=>"http://www.travian.com.ua/", :uk=>"http://www.travian.co.uk/", :ee=>"http://www.travian.co.ee/", :lv=>"http://www.travian.lv/", :ar=>"http://www.travian.com.ar/", :br=>"http://www.travian.com.br/", :cl=>"http://www.travian.cl/", :mx=>"http://www.travian.com.mx/", :us=>"http://www.travian.us/", :cn=>"http://www.travian.cc/", :hk=>"http://www.travian.hk/", :in=>"http://www.travian.in/", :id=>"http://www.travian.co.id/", :jp=>"http://www.travian.jp/", :my=>"http://www.travian.com.my/", :ph=>"http://www.travian.ph/", :kr=>"http://www.travian.co.kr/", :asia=>"http://www.travian.asia/", :vn=>"http://www.travian.com.vn/", :pk=>"http://www.travian.pk/", :ae=>"http://www.travian.ae/", :ir=>"http://www.travian.ir/", :eg=>"http://www.travian.com.eg/", :arabia=>"http://arabia.travian.com/", :sa=>"http://www.travian.com.sa/", :ma=>"http://www.travian.ma/", :za=>"http://www.travian.co.za/", :au=>"http://www.travian.com.au/", :nz=>"http://www.travian.co.nz/"}
      end
    end
  end
end
