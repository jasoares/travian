require 'spec_helper'

module Travian
  describe ServersHash do
    let(:klass) { ServersHash }
    let(:instance) { ServersHash.new({}) }

    it 'should extend Agent' do
      klass.should respond_to :get, :post
    end

    it 'should respond_to each' do
      instance.should respond_to :each
    end

    it 'should include Enumerable' do
      instance.should respond_to :map, :find, :select, :reject
    end

    context 'given the ServersHash built from the portuguese hub' do
      before(:all) { fake 'www.travian.pt/serverLogin.php', :post }
      before(:each) do
        hub = double('Hub', :host => 'http://www.travian.pt/')
        @hash = klass.build(hub)
      end

      subject  { @hash }

      it { should_not have_key :tc9 }

      it { should have(9).servers }

      it { should_not be_empty }

      its(:size) { should be 9 }

      its(:keys) { should === [:ts1, :ts10, :ts2, :ts3, :ts4, :ts5, :ts6, :ts7, :tx3] }

      after(:all) { unfake }
    end

    context 'given the ServersHash built from the german hub' do
      before(:all) { fake 'www.travian.de/serverLogin.php', :post }
      before(:each) do
        hub = double('Hub', :host => 'http://www.travian.de/')
        @hash = klass.build(hub)
      end

      subject  { @hash }

      it { should_not have_key :tcx8 }

      it { should have(7).servers }

      it { should_not be_empty }

      its(:size) { should be 7 }

      its(:keys) { should == [:ts1, :ts2, :ts3, :ts5, :ts7, :ts8, :tx3] }

      after(:all) { unfake }
    end

    context 'given the ServersHash built from the new zealand hub' do
      before(:all) do
        fake_redirection({'www.travian.co.nz/serverLogin.php' => 'www.travian.com.au'}, :post)
        fake 'www.travian.com.au/serverLogin.php', :post
      end

      before(:each) do
        hub = double('Hub', host: 'http://www.travian.co.nz/')
        @hash = klass.build(hub)
      end

      subject { @hash }

      it { should have(4).servers }

      its(:size) { should be 4 }

      it { should_not be_empty }

      after(:all) { unfake }
    end

    context 'given the ServersHash built from the south korean hub' do
      before(:all) do
        fake_redirection({'www.travian.co.kr/serverLogin.php' => 'www.travian.com/serverLogin.php'}, :post)
        fake 'www.travian.com/serverLogin.php', :post
      end

      before(:each) do
        hub = double('Hub', host: 'http://www.travian.co.kr/')
        @hash = klass.build(hub)
      end

      subject { @hash }

      it { should have(9).servers }

      its(:size) { should be 9 }

      it { should_not be_empty }

      after(:all) { unfake }
    end

    describe '.new' do
      it 'raises ArgumentError when passed an argument that is not a Hash' do
        expect { klass.new(123) }.to raise_error(ArgumentError)
      end
    end

    describe '.build' do
      before(:all) { fake 'www.travian.pt/serverLogin.php', :post }

      before(:each) do
        @hub = double('Hub', host: 'http://www.travian.pt/')
      end

      it 'returns a Hash object' do
        klass.build(@hub).should be_a ServersHash
      end
      
      it 'calls LoginData.new to create the object to return' do
        klass.should_receive(:new).with(kind_of(Hash)).once
        klass.build(@hub)
      end

      after(:all) { unfake }
    end
  end
end
