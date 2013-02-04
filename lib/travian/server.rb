require 'travian/parsers/login_data'
require 'travian/parsers/server_data'

module Travian
  class Server
    extend Forwardable
    include UriHelper

    attr_reader :host, :hub, :name, :start_date, :players

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

    alias :code :subdomain

    def world_id
      server_data unless @world_id; @world_id
    end

    def speed
      server_data unless @speed; @speed
    end

    def version
      server_data unless @version; @version
    end

    def restart_date
      server_data unless @world_id; @restart_date
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
      server_data = ServerData.parse(Agent.server_data(host))
      @version, @world_id, @speed, @restart_date = server_data
    end
  end
end
