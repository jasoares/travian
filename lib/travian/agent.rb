require 'travian/exceptions'
require 'httparty'

module Travian
  module Agent

    MAX_TRIES = 3
    DEFAULT_OPTIONS = {timeout: 6}

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
      rescue Timeout::Error, Errno::ETIMEDOUT, SocketError => e
        try += 1
        retry unless try == MAX_TRIES
        raise Travian::ConnectionTimeout.new(path, e)
      end
    end
  end
end
