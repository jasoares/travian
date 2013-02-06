require 'forwardable'

module Travian
  class ServersHash
    extend Forwardable
    include Enumerable

    def_delegators :@hash, :[], :empty?, :size, :keys, :has_key?, :values, :each_pair

    def initialize(hash)
      raise ArgumentError unless hash.is_a? Hash
      @hash = hash
    end

    def each
      @hash.values.each do |server|
        yield server
      end
    end

    def ==(other)
      self.zip(other).all? {|server1, server2| server1 == server2 }
    end

    class << self

      def build(servers_hash)
        hash = {}
        servers_hash.each_pair do |code, server_data|
          server = Server.new(*server_data.values)
          hash[code] = server unless server.classic?
        end
        ServersHash.new(hash)
      end

    end
  end
end
