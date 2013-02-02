require 'travian/servers_hash'
require 'yaml'

module Travian
  class Hub
    include UriHelper

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

    def servers_hash
      @servers_hash ||= LoginData.parse(Agent.login_data(host))
    end

    def login_data(server_code=nil)
      server_code ? servers_hash[server_code.to_sym] : servers_hash
    end

    def mirror?
      redirected? || borrows_servers?
    end

    def mirrored_hub
      @mirrored_hub ||= if mirror?
        Travian.hubs.find {|h| h.host == mirrored_host }
      else
        nil
      end
    end

    def location
      unless @location
        location = Agent.redirected_location(host)
        @location = UriHelper.strip_protocol(location)
      end
      @location
    end

    def ==(other)
      self.host == other.host && self.code == other.code
    end

    def redirected?
      location != host
    end

    def mirrored_host
      return nil unless mirror?
      return location if redirected?
      "www.travian.#{servers.first.tld}"
    end

    private

    def borrows_servers?
      !servers.empty? && self.tld != servers.first.tld
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
end
