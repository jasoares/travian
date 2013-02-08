require 'travian/parsers/register_data'
require 'travian/parsers/login_data'
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
      data.values
    end

    def [](server_code)
      data[server_code.to_sym]
    end

    def loginable_servers
      login_data.keys.map {|server_code| data[server_code] }.reject(&:nil?)
    end

    def preregisterable_servers
      register_data.keys.map {|server_code| data[server_code] }
    end

    def mirror?
      redirected? || borrows_servers?
    end

    def mirrored_hub
      @mirrored_hub ||= if mirror?
        Travian.hubs(mirrors: true).find {|h| h.host == mirrored_host }
      else
        nil
      end
    end

    def location
      @location ||= Agent.redirected_location(host)
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

    def data
      @data ||= all_data.values.inject({}) do |hash, server_data|
        server = Server.new(*server_data.values)
        hash[server.code.to_sym] = server
        hash
      end
    end

    def all_data
      login_data.merge(register_data)
    end

    def register_data
      @register_data ||= RegisterData.parse(Agent.register_data(host), self)
    end

    def login_data
      @login_data ||= LoginData.parse(Agent.login_data(host))
    end

    class << self

      def valid?(code)
        CODES.keys.include? code.to_sym
      end

    end

  end
end
