require 'travian/version'
require 'travian/uri_helper'
require 'travian/agent'
require 'travian/parsers/status_data'
require 'travian/parsers/hubs_data'
require 'travian/hub'
require 'travian/server'

module Travian
  extend self

  MAIN_HUB = 'www.travian.com'

  def data
    @@data ||= hubs_data.inject({}) do |hash, hub|
      hash[hub[0]] = Hub.new(*hub)
      hash
    end
  end

  def hubs(options={})
    options[:mirrors] ? data.values : data.values.reject(&:mirror?)
  end

  def servers
    (running_servers + preregisterable_servers + status_servers).uniq(&:host)
  end

  def preregisterable_servers
    hubs.inject([]) {|sum,hub| sum += hub.preregisterable_servers }
  end

  def running_servers
    hubs.inject([]) {|sum,hub| sum += hub.loginable_servers }
  end

  def restarting_servers
    (preregisterable_servers + status_servers.select(&:restarting?)).uniq {|s| s.host }
  end

  def status_servers
    status_data.values.inject(&:+).map {|s| Server(s) }
  end

  def clear
    @@data = nil
  end

  def preload(options=:all)
    options == :servers ? preload_servers : preload_server_attributes
  end

  def Hub(obj)
    raise ArgumentError unless obj.is_a?(String) || obj.respond_to?(:host)
    hub_code = UriHelper.hub_code(obj.is_a?(String) ? obj : obj.host).to_sym
    data[hub_code]
  end

  def Server(obj)
    error_msg = "Object passed must be a string host or respond to :host"
    raise ArgumentError, error_msg unless obj.respond_to?(:host) or obj.is_a?(String)
    host = obj.is_a?(String) ? obj : obj.host
    hub_code = UriHelper.hub_code(host).to_sym
    server_code = UriHelper.server_code(host).to_sym
    data[hub_code][server_code] or Server.new(host)
  end

  private

  def preload_servers
    hubs.map do |hub|
      Thread.new { hub.servers }
    end.each(&:join)
  end

  def preload_server_attributes
    preload_servers
    hubs.each do |hub|
      hub.servers.map do |server|
        Thread.new { server.attributes }
      end.each(&:join)
    end
  end

  def status_data
    @@status_data ||= StatusData.parse(Agent.status_data)
  end

  def hubs_data
    @@hubs_data ||= HubsData.parse(Agent.hubs_data)
  end

end
