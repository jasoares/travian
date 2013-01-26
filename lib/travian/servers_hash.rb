require 'forwardable'
require 'nokogiri'
require 'httparty'

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
      @hash.values
    end

    class << self
      include Agent

      def build(hub)
        data = Nokogiri::HTML(fetch_servers(hub.host))
        hash = LoginData.split_servers(data).inject({}) do |hash,server_data|
          host, code, name, start_date, players = LoginData.parse(server_data)
          server = Server.new(hub, host, code, name, start_date, players)
          hash[code.to_sym] = server unless server.classic?
          hash
        end
        ServersHash.new(hash)
      end

      def fetch_servers(host)
        uri = "#{host}serverLogin.php"
        post(uri).body
      end

    end
  end
end
