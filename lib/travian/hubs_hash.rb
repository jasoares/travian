require 'travian/hub'
require 'forwardable'

module Travian
  class HubsHash
    extend Forwardable
    include Enumerable

    def_delegators :@hash, :[], :size, :empty?, :keys, :has_key?, :values, :each_pair

    def initialize(hash)
      @hash = hash
    end

    def each
      @hash.values.each do |hub|
        yield hub
      end
      @hash.values
    end

    class << self

      def build(hubs_hash)
        hash = {}
        hubs_hash.each {|code, host| hash[code] = Hub.new(code, host) }
        HubsHash.new(hash)
      end

    end
  end
end
