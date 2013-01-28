require 'travian/parsers/login_data'
require 'travian/parsers/server_data'

module Travian
  class Server
    extend Forwardable

    def_delegators :server_data, :world_id, :speed, :version, :restart_date

    attr_reader :hub

    def initialize(hub, login_data, host = nil)
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
      @login_data ? @login_data.host : @host
    end

    def code
      self.class.code(host)
    end

    alias :subdomain :code

    def name
      @login_data ? @login_data.name : nil
    end

    def start_date
      @login_data ? @login_data.start_date : nil
    end

    def players
      @login_data ? @login_data.players : nil
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
      start_date
    end

    private

    def server_data
      @server_data ||= Travian::ServerData(Agent.server_data(host))
    end

    class << self

      def code(host)
        host[%r{http://(\w+)\.travian\..+/}]; $1
      end

      def [](obj, code="")
        hub, server = if obj.respond_to?(:hub) && obj.respond_to?(:code) && obj.hub.respond_to?(:code)
          [obj.hub.code, obj.code]
        elsif obj.is_a?(String) || obj.is_a?(Symbol) and code.is_a?(String) || code.is_a?(Symbol)
          [obj, code]
        else
          raise ArgumentError
        end
        Travian.hubs[hub.to_sym].servers[server.to_sym]
      end

    end

  end
end
