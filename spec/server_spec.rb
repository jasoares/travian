require 'spec_helper'

module Travian
  describe Server do
    let(:hub) { Hub.new('pt', 'http://www.travian.pt/') }
    let(:server) { Server.new(hub, nil, 'http://tx3.travian.pt/') }

    it 'should include UriHelper' do
      server.should respond_to :tld, :subdomain
    end

    subject { server }

    its(:hub) { should == hub }

    describe '#host' do
      it 'returns "http://tx3.travian.pt/" when the @host is not nil' do
        server.host.should == 'http://tx3.travian.pt/'
      end

      it 'does not call #login_data when @host is not nil' do
        server.should_not_receive(:login_data)
        server.host
      end

      it 'returns LoginData#host if @host is nil' do
        server.instance_variable_set(:@host, nil)
        login_data = double('LoginData', host: 'http://ts1.travian.pt/')
        server.should_receive(:login_data).and_return(login_data)
        server.host.should == 'http://ts1.travian.pt/'
      end
    end

    shared_examples "a delegator to #login_data" do
      it "delegates to #login_data if it is not nil" do
        login_data = double('LoginData')
        login_data.should_receive(method).and_return(expected)
        server.should_receive(:login_data).twice.and_return(login_data)
        server.send(method)
      end

      it 'returns the return value of the call to login_data' do
        login_data = double('LoginData', method => expected)
        server.stub(login_data: login_data)
        server.send(method).should == expected
      end

      it "returns nil if login_data is nil" do
        server.stub(login_data: nil)
        server.send(method).should be nil
      end
    end

    describe '#name' do
      let(:method) { :name }
      let(:expected) { "Speed 3x" }

      it_behaves_like 'a delegator to #login_data'
    end

    describe '#start_date' do
      let(:method) { :start_date }
      let(:expected) { Date.today.to_datetime }

      it_behaves_like 'a delegator to #login_data'
    end

    describe '#players' do
      let(:method) { :players }
      let(:expected) { 3103 }

      it_behaves_like 'a delegator to #login_data'
    end

    shared_examples "a delegator to #server_data" do
      it "delegates to #server_data" do
        server_data = double('ServerData')
        server_data.should_receive(method)
        server.should_receive(:server_data).and_return(server_data)
        server.send(method)
      end
    end

    describe '#world_id' do
      let(:method) { :world_id }

      it_behaves_like 'a delegator to #server_data'
    end

    describe '#speed' do
      let(:method) { :speed }

      it_behaves_like 'a delegator to #server_data'
    end

    describe '#version' do
      let(:method) { :version }

      it_behaves_like 'a delegator to #server_data'
    end

    describe '#restart_date' do
      let(:method) { :restart_date }

      it_behaves_like 'a delegator to #server_data'
    end

    describe '#code' do
      it 'returns tx3 when host is "http://tx3.travian.pt/"' do
        server.stub(host: 'http://tx3.travian.pt/')
        server.code.should == 'tx3'
      end

      it 'returns arabiatx4 when host is "http://arabiatx4.travian.com/' do
        server.stub(host: 'http://arabiatx4.travian.pt/')
        server.code.should == 'arabiatx4'
      end
    end

    describe '#attributes' do
      it 'returns a hash with the server\'s attributes' do
        server.stub(host: 'http://tx3.travian.pt/', code: 'tx3', name: 'Speed 3x', world_id: 'ptx18', speed: 3)
        server.attributes.should == {
          host: 'http://tx3.travian.pt/',
          code: 'tx3',
          name: 'Speed 3x',
          world_id: 'ptx18',
          speed: 3,
        }
      end
    end

    describe '#classic?' do
      let(:hub) { double('Hub') }

      it 'returns true when code is tcx8' do
        server.stub(code: 'tcx8')
        server.should be_classic
      end

      it 'returns true when code is tc27' do
        server.stub(code: 'tc27')
        server.should be_classic
      end

      it 'returns false when code is tx3' do
        server.stub(code: 'tx3')
        server.should_not be_classic
      end

      it 'returns false when code is ts4' do
        server.stub(code: 'ts4')
        server.should_not be_classic
      end
    end

    describe '#restarting?' do
      it 'returns true if #restart_date is not nil' do
        server.stub(restart_date: Date.today.to_datetime)
        server.should be_restarting
      end

      it 'returns false if #restart_date is nil' do
        server.stub(restart_date: nil)
        server.should_not be_restarting
      end
    end

    describe '#running?' do
      it 'returns true if #start_date is not nil' do
        server.stub(start_date: Date.today.to_datetime)
        server.should be_running
      end

      it 'returns false if #start_date is nil' do
        server.stub(start_date: nil)
        server.should_not be_running
      end
    end

    describe '#ended?' do
      it 'returns true if #restarting? is true' do
        server.stub(restarting?: true)
        server.should be_ended
      end

      it 'returns true if #start_date is nil' do
        server.stub(restarting?: false, start_date: nil)
        server.should be_ended
      end

      it 'returns false when both #restarting is false and #start_date is not nil' do
        server.stub(restarting?: false, start_date: Date.today.to_datetime)
        server.should_not be_ended
      end
    end

    describe '#server_data' do
      it 'delegates the fetching of html data to Agent.server_data' do
        Agent.should_receive(:server_data).with('http://tx3.travian.pt/')
        server.send(:server_data)
      end

      it 'delegates the creation of the ServerData object to Travian::ServerData' do
        data = double('Nokogiri')
        Agent.stub(server_data: data)
        Travian.should_receive(:ServerData).with(data)
        server.send(:server_data)
      end

      it 'returns a ServerData object' do
        data = double('Nokogiri')
        Agent.stub(server_data: data)
        server.send(:server_data).should be_a ServerData
      end
    end

    describe '#login_data' do
      context 'given a Server object created without login_data' do
        it 'returns nil if hub does not have this server' do
          server.stub_chain(:hub, :servers, :[]).and_return(nil)
          server.send(:login_data).should be_nil
        end

        it 'returns a LoginData object if hub has this server' do
          login_data = double('LoginData')
          server.stub_chain(:hub, :servers, :[], :login_data).and_return(login_data)
          server.send(:login_data).should be login_data
        end
      end

      context 'given a Server object created with login_data' do
        it 'returns the LoginData object the instance variable' do
          login_data = double('LoginData')
          server.instance_variable_set(:@login_data, login_data)
          server.send(:login_data).should be login_data
        end
      end
    end

    describe '.[]' do
      before(:all) do
        fake 'www.travian.com'
        fake 'www.travian.pt'
        fake 'www.travian.pt/serverLogin.php', :post
      end

      it 'returns a Server object when passed a valid object' do
        server = double('Server', :code => 'tx3')
        server.stub_chain(:hub, :code).and_return('pt')
        Travian.hubs[:pt].servers.should_receive(:[]).with(:tx3).and_call_original
        Travian.hubs.should_receive(:[]).with(:pt).and_call_original
        Server[server]
      end

      it 'returns a Server object when passed the hub code and the server code' do
        Travian.hubs[:pt].servers.should_receive(:[]).with(:tx3).and_call_original
        Travian.hubs.should_receive(:[]).with(:pt).and_call_original
        Server[:pt, :tx3]
      end

      it 'returns nil when passed an invalid hub or an invalid server code' do
        Server[:pt, :tx4].should be nil
      end

      it 'raises ArgumentError when passed an invalid object like an integer' do
        expect { Server[3] }.to raise_error(ArgumentError)
      end

      it 'raises ArgumentError when passed invalid arguments like :pt, nil' do
        expect { Server[:pt, nil] }.to raise_error(ArgumentError)
      end
    end

    describe '.new' do
      it 'raises ArgumentError when passed nil as the hub' do
        expect { Server.new(nil, nil) }.to raise_error(
          ArgumentError,
          /hub can't be nil./
        )
      end

      it 'raises ArgumentError when passed nil as the login_data and as the host' do
        hub = double('Hub')
        expect { Server.new(hub, nil) }.to raise_error(
          ArgumentError,
          /Either login_data or host must have a value./
        )
      end
    end
  end
end
