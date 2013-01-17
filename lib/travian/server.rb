require 'httparty'

module Travian
  class Server
    include HTTParty

    attr_reader :host, :code, :name, :start_date, :players

    def initialize(host, code, name, start_date, players)
      @host, @code, @name = host, code.to_s, name
      @start_date, @players = start_date, players
    end

    def attributes
      {
        code:       code,
        host:       host,
        name:       name,
        start_date: start_date,
        world_id:   world_id,
        version:    version,
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

    private

    def load_info
      info = select_info(Nokogiri::HTML(fetch_server_data))
      @world_id = parse_world_id(info)
      @version = parse_version(info)
      @speed = parse_speed(info)
    end

    def fetch_server_data
      HTTParty.get("#{host}").body
    rescue Exception => e
      raise Travian::ConnectionTimeout, e
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
  end
end
