require 'travian/agent'
require 'travian/uri_helper'
require 'travian/parsers/server_data'
require 'forwardable'

module Travian
  class Server
    extend Forwardable
    include UriHelper

    attr_reader :host, :start_date, :players

    def initialize(host, name=nil, start_date=nil, players=0)
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
      Travian.data[hub_code.to_sym]
    end

    def name
      @name ||= restarting? ? server_register_data : nil
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

    def server_id
      @server_id ||= server_data[4]
    end

    def classic?
      code[/tcx?\d/] ? true : false
    end

    def ended?
      start_date.nil?
    end

    def restarting?
      ended? && !restart_date.nil?
    end

    def running?
      !ended?
    end

    def ==(other)
      host == other.host
    end

    private

    def server_data
      @version, @world_id, @speed, @restart_date, @server_id = ServerData.parse(Agent.server_data(host))
    end

    def server_register_data
      RegisterData.parse_selected_name(Agent.register_data(hub.host, server_id))
    end

    def classic_speed
      code[/tcx(\d+)/] ? $1.to_i : 1
    end
  end
end
