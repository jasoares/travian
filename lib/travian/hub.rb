require 'travian/servers_hash'
require 'httparty'
require 'nokogiri'
require 'yaml'

module Travian
  class Hub
    include Agent

    CODES = YAML.load_file(
      File.expand_path('../../../data/hub_codes.yml', __FILE__)
    )

    attr_reader :code, :host, :name, :language

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
      @servers ||= ServersHash.build(is_redirected? ? mirrored_hub : self)
    end

    def mirror?
      is_redirected? || borrows_servers?
    end

    def mirrored_hub
      @mirrored_hub ||= if is_redirected? || borrows_servers?
        Travian.hubs.select {|h| h.matches_host?(mirrored_host) }.first
      else
        nil
      end
    end

    def location
      @location ||= begin
        get(host, limit: 1)
        host
      rescue HTTParty::RedirectionTooDeep => e
        location = e.response.header['Location']
        location[/\/$/] ? location : location + '/'
      end
    end

    def ==(other)
      self.host == other.host && self.code == other.code
    end

    def is_redirected?
      location != host
    end

    def borrows_servers?
      !servers.empty? && !matches_host?(servers_tld)
    end

    protected

    def matches_host?(term)
      host.match(/#{term}/) ? true : false
    end

    private

    def mirrored_host
      is_redirected? ? location : borrows_servers? ? servers_tld : nil
    end

    def servers_tld
      servers.first.host[/travian\..+\//]
    end
  end
end
