require 'travian/version'
require 'travian/exceptions'
require 'travian/agent'
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
    threads = @@hubs.inject([]) do |pool,hub|
      case options
      when :servers then pool << Thread.new { hub.servers }
      when :mirrors then pool << Thread.new { hub.mirrored_hub }
      else
        pool + [Thread.new { hub.mirrored_hub}, Thread.new { hub.servers.each(&:attributes) }]
      end
    end.each(&:join)
  end

end
