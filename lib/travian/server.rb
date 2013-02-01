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
      @world_id || server_data and @world_id
    end

    def speed
      @speed || server_data and @speed
    end

    def version
      @version || server_data and @version
    end

    def restart_date
      @restart_date || server_data and @restart_date
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

  def Server(obj)
    error_msg = "Object passed must be a string host or respond to :host"
    raise ArgumentError, error_msg unless obj.respond_to?(:host) or obj.is_a?(String)
    host = obj.is_a?(String) ? obj : obj.host
    hub_code = UriHelper.hub_code(host)
    server_code = UriHelper.server_code(host)
    login_data = Travian.hubs[hub_code.to_sym].login_data(server_code)
    login_data ? Server.new(*login_data.values) : Server.new(host)
  end
end
