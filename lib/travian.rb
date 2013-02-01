require 'travian/version'
require 'travian/exceptions'
require 'travian/uri_helper'
require 'travian/agent'
require 'travian/parsers/hubs_data'
require 'travian/hubs_hash'
require 'travian/hub'
require 'travian/servers_hash'
require 'travian/server'

module Travian
  extend self

  MAIN_HUB = 'http://www.travian.com/'

  def hubs(options={})
    @@hubs ||= HubsHash.build
    options[:preload] && preload(options[:preload])
    @@hubs
  end

  def clear
    @@hubs = nil
  end

  def preload(options=:all)
    options == :servers ? preload_servers : preload_server_attributes
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
