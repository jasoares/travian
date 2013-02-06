require 'travian/parsers/login_data'
require 'travian/parsers/server_data'

module Travian
  class Server
    extend Forwardable
    include UriHelper

    attr_reader :host, :name, :start_date, :players

    def initialize(host, name=nil, start_date=nil, players=nil)
      raise ArgumentError, "Must provide a host." unless host
      @host, @name, @start_date, @players = host, name, start_date, players
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

    def hub
      Travian.hubs[hub_code.to_sym]
    end

    alias :code :subdomain

    def world_id
      @world_id ||= classic? ? nil : server_data[1]
    end

    def speed
      @speed ||= classic? ? classic_speed : server_data[2]
    end

    def version
      @version ||= classic? ? "3.6" : server_data[0]
    end

    def restart_date
      @restart_date ||= classic? ? nil : (@world_id ? nil : server_data[3])
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

    def ==(other)
      host == other.host
    end

    private

    def server_data
      @version, @world_id, @speed, @restart_date = ServerData.parse(Agent.server_data(host))
    end

    def classic_speed
      code[/tcx(\d+)/] ? $1.to_i : 1
    end
  end
end
