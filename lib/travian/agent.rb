require 'travian/exceptions'
require 'httparty'
require 'nokogiri'

module Travian
  module Agent
    extend self

    MAX_TRIES = 3
    DEFAULT_OPTIONS = {timeout: 6}

    def hubs_data
      Nokogiri::HTML(get(MAIN_HUB).body)
    end

    def login_data(host)
      uri = URI(host)
      begin
        uri.path = '/serverLogin.php'
        resp = post(uri.to_s, limit: 1)
        Nokogiri::HTML(resp.body) if resp
      rescue HTTParty::RedirectionTooDeep => e
        uri = URI(e.response.header['Location'])
        retry
      end
    end

    def server_data(host)
      Nokogiri::HTML(get("#{host}").body)
    end

    def status_data
      Nokogiri::HTML(get('http://status.travian.com'))
    end

    def redirected_location(host)
      begin
        get(host, limit: 1)
        host
      rescue HTTParty::RedirectionTooDeep => e
        e.response.header['Location']
      end
    end

    def get(path, options={}, &block)
      request(:get, path, options, &block)
    end

    def post(path, options={}, &block)
      request(:post, path, options, &block)
    end

    private

    def request(req, path, options={}, &block)
      try = 0
      options.merge!(DEFAULT_OPTIONS)
      begin
        HTTParty.send(req, path, options, &block)
      rescue Timeout::Error, Errno::ETIMEDOUT, Errno::ECONNREFUSED, SocketError => e
        try += 1
        retry unless try == MAX_TRIES
        raise Travian::ConnectionTimeout.new(path, e)
      end
    end
  end
end
