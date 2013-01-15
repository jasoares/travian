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

      def build(hub)
        data = Nokogiri::HTML(fetch_servers(hub.host))
        hash = split_servers(data).inject({}) do |hash,server_data|
          host = parse_host(server_data)
          code = parse_subdomain(host).to_sym
          name = parse_name(server_data)
          start_date = parse_start_date(server_data)
          players = parse_players(server_data)
          server = Server.new(host, code, name, start_date, players)
          hash[code] = server unless server.classic?
          hash
        end
        ServersHash.new(hash)
      end

      def fetch_servers(host)
        HTTParty.post("#{host}serverLogin.php").body
      end

      def split_servers(data)
        data.css('div[class~="server"]')
      end

      def parse_host(server_data)
        server_data.search('a.link').first['href']
      end

      def parse_subdomain(host)
        host[%r{http://(\w+)\.travian\..+/}]; $1
      end

      def parse_name(server_data)
        server_data.search('div')[0].text.gsub(/[\s]/, '')
      end

      def parse_players(server_data)
        server_data.search('div')[1].text.gsub(/[^\d]/, '').to_i
      end

      def parse_start_date(server_data)
        Date.today - server_data.search('div')[2].text.gsub(/[^\d]/, '').to_i
      end

    end
  end
end
