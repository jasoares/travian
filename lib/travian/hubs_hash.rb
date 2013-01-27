require 'forwardable'

module Travian
  class HubsHash
    extend Forwardable
    extend HubsData
    extend Agent
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

      def build
        hubs = parse(hubs_data)
        HubsHash.new(
          hubs.inject({}) do |hash,hub|
            hash[hub[0]] = Hub.new(hub[0], hub[1])
            hash
          end
        )
      end

    end
  end
end
