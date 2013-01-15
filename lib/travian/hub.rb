require 'travian/servers_hash'
require 'httparty'
require 'nokogiri'
require 'yaml'

module Travian
  class Hub
    include HTTParty

    CODES = YAML.load_file(
      File.expand_path('../../../data/hub_codes.yml', __FILE__)
    )

    attr_reader :code, :host, :name, :language, :mirrored_host

    def initialize(code, host)
      @code, @host, @name = code, host, CODES[code][:hub]
      @language = CODES[code][:language]
    end

    def attributes
      {
        code:     code.to_s,
        host:     host,
        name:     name,
        language: language
      }
    end

    def servers
      @servers ||= ServersHash.build(self)
    end

    def is_mirror?
      !servers.empty? && servers_hosts_match_tld ? false : true
    end

    private

    def servers_hosts_match_tld
      host.index(servers.first.host[/travian\..+\//])
    end

    class << self

      def parse(data)
        hash = Parser.to_ruby_hash(select(data))
        hash = extract_hubs_from(hash)
        build_hubs_hash(hash)
      end

      private

      def select(data)
        data.css('div#country_select').text.gsub(/\n|\t/, '')[/\(({container:[^\)]+).+/]; $1
      end

      def extract_hubs_from(hash)
        hash[:flags].values.inject(&:merge).reject {|k,v| k == :kr }
      end

      def build_hubs_hash(hubs)
        hubs.inject({}) do |hash,hub|
          hash[hub[0]] = Hub.new(hub[0], hub[1])
          hash
        end
      end

    end
  end
end
