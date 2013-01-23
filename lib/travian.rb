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

  def hubs
    @@hubs ||= HubsHash.build
  end

  def clear
    @@hubs = nil
  end

end
