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

    def leads_to
      HTTParty.get(host, limit: 1)
      host
    rescue HTTParty::RedirectionTooDeep => e
      e.response.header['Location'] + '/'
    end

    def ==(other)
      self.host == other.host && self.code == other.code
    end

    private

    def servers_hosts_match_tld
      host.index(servers.first.host[/travian\..+\//])
    end
  end
end
