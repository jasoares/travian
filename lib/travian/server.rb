require 'travian/parsers/server_data'

module Travian
  class Server
    extend LoginData

    attr_reader :hub, :host, :name, :players

    def initialize(hub, host, name, start_date=nil, players=0)
      @hub, @host, @name = hub, host, name
      @start_date, @players = start_date, players
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

    def code
      self.class.code(host)
    end

    alias :subdomain :code

    def world_id
      server_data.world_id
    end

    def version
      server_data.version
    end

    def speed
      server_data.speed
    end

    def restart_date
      server_data.restart_date
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
      start_date && start_date < DateTime.now ? true : false
    end

    def start_date
      @start_date ||= parse_hub_page_start_date
    end

    private

    def server_data
      @server_data ||= ServerData.new(self)
    end

    def parse_start_date(data)
      parse_hub_page_start_date or parse_restart_page_start_date(data)
    end

    def parse_hub_page_start_date
      hub.servers[code.to_sym].start_date if hub.servers[code.to_sym]
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

      def build(hub, login_data)
        Server.new(hub, *parse(login_data))
      end

    end

  end
end
