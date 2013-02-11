require 'travian/exceptions'
require 'httparty'
require 'nokogiri'

module Travian
  module Agent
    extend self
    extend UriHelper::ClassMethods

    MAX_TRIES = 3
    USER_AGENT = "Mozilla/5.0 (Windows NT 6.2; Win64; x64; rv:16.0.1) Gecko/20121011 Firefox/16.0.1"
    DEFAULT_OPTIONS = { timeout: 6, headers: { 'User-Agent' => USER_AGENT } }

    def hubs_data
      Nokogiri::HTML(get(MAIN_HUB).body)
    end

    def login_data(host)
      hub_data(host, "/serverLogin.php")
    end

    def register_data(host, server_id=nil)
      path = "/register.php" + (server_id ? "?server=#{server_id}" : "")
      hub_data(host, path)
    end

    def hub_data(host, path)
      begin
        uri = "#{host}#{path}"
        resp = post(uri.to_s, limit: 1)
        Nokogiri::HTML(resp.body) if resp
      rescue HTTParty::RedirectionTooDeep => e
        host = URI(e.response.header['Location']).host
        retry
      end
    end

    def server_data(host)
      Nokogiri::HTML(get("#{host}").body)
    end

    def status_data
      Nokogiri::HTML(get('status.travian.com'))
    end

    def redirected_location(host)
      begin
        post("#{host}/register.php", limit: 1)
        host
      rescue HTTParty::RedirectionTooDeep => e
        URI(e.response.header['Location']).host
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
        HTTParty.send(req, "http://#{path}", options, &block)
      rescue Timeout::Error, Errno::ETIMEDOUT, Errno::ECONNREFUSED, SocketError => e
        try += 1
        retry unless try == MAX_TRIES
        raise Travian::ConnectionTimeout.new(path, e)
      end
    end
  end
end
