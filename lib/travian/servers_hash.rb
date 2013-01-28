require 'forwardable'

module Travian
  class ServersHash
    extend Forwardable
    extend Agent
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
      @hash.values
    end

    class << self

      def build(hub)
        data = Agent.login_data(hub.host)
        servers_hash = LoginData.split_servers(data).inject({}) do |hash,login_data|
          server = Server.new(hub, login_data)
          hash[server.code.to_sym] = server unless server.classic?
          hash
        end
        ServersHash.new(servers_hash)
      end

    end
  end
end
