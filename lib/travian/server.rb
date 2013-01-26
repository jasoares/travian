require 'httparty'

module Travian
  class Server
    include Agent
    extend LoginData

    attr_reader :hub, :host, :code, :name, :players

    def initialize(hub, host, code, name, start_date=nil, players=0)
      @hub, @host, @code, @name = hub, host, code.to_s, name
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

    alias :subdomain :code

    def world_id
      @world_id || load_info and @world_id
    end

    def version
      @version || load_info and @version
    end

    def speed
      @speed || load_info and @speed
    end

    def classic?
      code[/tcx?\d/] ? true : false
    end

    def ended?
      restarting? or start_date.nil?
    end

    def restarting?
      start_date && start_date > DateTime.now ? true : false
    end

    def running?
      start_date && start_date < DateTime.now ? true : false
    end

    def start_date
      @start_date || load_info and @start_date
    end

    private

    def load_info
      server_data = Nokogiri::HTML(fetch_server_data)
      info = select_info(server_data)
      @start_date ||= parse_start_date(server_data)
      @world_id = parse_world_id(info)
      @version = parse_version(info)
      @speed = parse_speed(info)
    end

    def fetch_server_data
      get("#{host}").body
    end

    def parse_version(info)
      info[/Travian\.Game\.version = '(.+)';/]; $1
    end

    def parse_world_id(info)
      info[/Travian\.Game\.worldId = '(.+)';/]; $1
    end

    def parse_speed(info)
      info[/Travian\.Game\.speed = (.+);/]; $1.to_i
    end

    def select_info(data)
      data.css('head script').last.text
    end

    def parse_start_date(data)
      parse_hub_page_start_date or parse_restart_page_start_date(data)
    end

    def parse_hub_page_start_date
      hub.servers[code.to_sym].start_date if hub.servers[code.to_sym]
    end

    def parse_restart_page_start_date(data)
      date_str = select_start_date(data)
      date_str.empty? ? nil : DateTime.strptime(Server.sanitize_date_format(date_str), "%d.%m.%y %H:%M %:z")
    end

    def select_start_date(data)
      data.css('div#worldStartInfo span.date').text
    end

    def self.sanitize_date_format(date_str)
      date_str.strip.gsub(/[\(\)]|gmt\s|\.$/i, '')
    end

    class << self

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
