require 'travian/parsers/login_data'
require 'travian/parsers/server_data'

module Travian
  class Server
    extend Forwardable
    include UriHelper

    def_delegators :server_data, :world_id, :speed, :version, :restart_date

    attr_reader :hub

    def initialize(hub, login_data, host = nil)
      raise ArgumentError, "hub can't be nil." unless hub
      raise ArgumentError, "Either login_data or host must have a value." unless login_data or host
      @hub = hub
      @login_data = login_data ? Travian::LoginData(login_data) : nil
      @host = host
    end

    def attributes
      {
        code:       code,
        host:       host,
        name:       name,
        world_id:   world_id,
        speed:      speed
      }
    end

    def host
      # attemps to retrieve host from instance variable first for
      # performance, instead of making an external call in case of
      # an externally built server
      @host ? @host : login_data.host
    end

    alias :code :subdomain

    def name
      login_data ? login_data.name : nil
    end

    def start_date
      login_data ? login_data.start_date : nil
    end

    def players
      login_data ? login_data.players : nil
    end

    def classic?
      code[/tcx?\d/] ? true : false
    end

    def ended?
      restarting? or start_date.nil?
    end

    def restarting?
      restart_date ? true : false
    end

    def running?
      start_date ? true : false
    end

    protected

    def login_data
      @login_data ||= hub.servers[code.to_sym] ? hub.servers[code.to_sym].login_data : nil
    end

    private

    def server_data
      @server_data ||= Travian::ServerData(Agent.server_data(host))
    end
  end

  def Server(obj)
    error_msg = "Object passed must respond to :hub and :host"
    raise ArgumentError, error_msg unless obj.respond_to?(:host) && obj.respond_to?(:hub)
    hub = Travian::Hub(obj.hub)
    Server.new(hub, nil, obj.host)
  end
end
