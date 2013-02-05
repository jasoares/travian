require 'travian/version'
require 'travian/exceptions'
require 'travian/uri_helper'
require 'travian/agent'
require 'travian/parsers/register_data'
require 'travian/parsers/status_data'
require 'travian/parsers/hubs_data'
require 'travian/hubs_hash'
require 'travian/hub'
require 'travian/servers_hash'
require 'travian/server'

module Travian
  extend self
  extend Agent

  MAIN_HUB = 'www.travian.com'

  def hubs(options={})
    @@hubs ||= HubsHash.build(HubsData.parse(hubs_data))
    options[:preload] && preload(options[:preload])
    @@hubs
  end

  def clear
    @@hubs = nil
  end

  def preload(options=:all)
    options == :servers ? preload_servers : preload_server_attributes
  end

  def Hub(obj)
    raise ArgumentError unless obj.respond_to?(:code) && obj.respond_to?(:host)
    Hub.new(obj.code.to_sym, obj.host)
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

  private

  def preload_servers
    @@hubs.map do |hub|
      Thread.new { hub.servers }
    end.each(&:join)
  end

  def preload_server_attributes
    preload_servers
    @@hubs.each do |hub|
      hub.servers.inject([]) do |pool,server|
        pool << Thread.new { server.attributes }
      end.each(&:join)
    end
  end

end
