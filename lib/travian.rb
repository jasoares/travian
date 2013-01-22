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
    @@hubs.map {|hub| Thread.new { hub.mirrored_hub } }.each(&:join) if options[:preload]
    @@hubs
  end

  def clear
    @@hubs = nil
  end

end
