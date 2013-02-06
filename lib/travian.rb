require 'travian/version'
require 'travian/uri_helper'
require 'travian/agent'
require 'travian/parsers/status_data'
require 'travian/parsers/hubs_data'
require 'travian/hubs_hash'
require 'travian/hub'
require 'travian/server'

module Travian
  extend self

  MAIN_HUB = 'www.travian.com'

  def hubs(options={})
    @@hubs ||= HubsHash.build(HubsData.parse(Agent.hubs_data))
    options[:preload] && preload(options[:preload])
    @@hubs
  end

  def servers
    hubs.reject(&:mirror?).inject([]) {|sum,hub| sum += hub.servers.to_a }
  end

  def preregisterable_servers
    hubs.map(&:preregisterable_servers).inject(&:+)
  end

  def restarting_servers
    status_restarting = status_servers.reject(&:running?).select(&:restarting?)
    (status_restarting + preregisterable_servers).uniq {|s| s.host }
  end

  def status_servers
    status_data.values.inject(&:+).map {|s| Server(s) }
  end

  def clear
    @@hubs = nil
  end

  def preload(options=:all)
    options == :servers ? preload_servers : preload_server_attributes
  end

  def Hub(obj)
    raise ArgumentError unless obj.is_a?(String) || obj.respond_to?(:host)
    hub_code = UriHelper.hub_code(obj.is_a?(String) ? obj : obj.host).to_sym
    Travian.hubs[hub_code]
  end

  def Server(obj)
    error_msg = "Object passed must be a string host or respond to :host"
    raise ArgumentError, error_msg unless obj.respond_to?(:host) or obj.is_a?(String)
    host = obj.is_a?(String) ? obj : obj.host
    hub_code = UriHelper.hub_code(host).to_sym
    server_code = UriHelper.server_code(host).to_sym
    Travian.hubs[hub_code].servers[server_code] or Server.new(host)
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

  def status_data
    @@status_data ||= StatusData.parse(Agent.status_data)
  end

end
