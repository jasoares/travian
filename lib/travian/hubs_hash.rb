require 'forwardable'

module Travian
  class HubsHash
    extend Forwardable
    include Enumerable

    def_delegators :@hash, :[], :size, :keys, :has_key?, :values, :each_pair

    def initialize(hash)
      @hash = hash
    end

    def each
      @hash.values.each do |hub|
        yield hub
      end
      @hash.values
    end

    class << self

      def build(host)
        data = Nokogiri::HTML(fetch_hub_data)
        hash = js_hash_to_ruby_hash(select(data))
        hash = extract_hubs_from(hash)
        HubsHash.new(build_hubs_hash(hash))
      end

      def fetch_hub_data
        HTTParty.get(MAIN_HUB).body
      end

      def select(data)
        data.css('div#country_select').text.gsub(/\n|\t/, '')[/\(({container:[^\)]+).+/]; $1
      end

      def js_hash_to_ruby_hash(js_hash)
        Hash[eval(js_hash.gsub(/,'/, ", ").gsub(/':/, ": ").gsub(/\{'/, "{ "))]
      end

      def extract_hubs_from(hash)
        hash[:flags].values.inject(&:merge)
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
