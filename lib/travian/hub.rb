require 'travian/servers_hash'
require 'yaml'

module Travian
  class Hub
    include Agent

    CODES = YAML.load_file(
      File.expand_path('../../../data/hub_codes.yml', __FILE__)
    )

    attr_reader :code, :host, :name, :language

    def initialize(code, host)
      raise ArgumentError unless Hub.valid?(code)
      @code, @host, @name = code, host, CODES[code.to_sym][:hub]
      @language = CODES[code.to_sym][:language]
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

    def mirror?
      redirected? || borrows_servers?
    end

    def mirrored_hub
      @mirrored_hub ||= if redirected? || borrows_servers?
        Travian.hubs.find {|h| h.matches_host?(mirrored_host_pattern) }
      else
        nil
      end
    end

    def location
      unless @location
        location = redirected_location(host)
        @location = location[/\/$/] ? location : location + '/'
      end
      @location
    end

    def ==(other)
      self.host == other.host && self.code == other.code
    end

    def redirected?
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

    def mirrored_host_pattern
      redirected? ? location : borrows_servers? ? servers_tld : nil
    end

    def servers_tld
      servers.first.host[/travian\..+\//]
    end

    class << self

      def [](obj)
        raise ArgumentError unless (obj.is_a?(String) || obj.is_a?(Symbol) || obj.respond_to?(:code))
        key = obj.respond_to?(:code) ? obj.code : obj
        valid?(key) ? Travian.hubs[key.to_sym] : CODES.keys
      end

      def valid?(code)
        CODES.keys.include? code.to_sym
      end

    end

  end

  def Hub(obj)
    raise ArgumentError unless obj.respond_to?(:code) && obj.respond_to?(:host)
    Hub.new(obj.code.to_sym, obj.host)
  end
end
