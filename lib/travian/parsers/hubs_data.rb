module Travian
  module HubsData
    extend self

    def parse(data)
      js_hash = parse_hubs_js_hash(data)
      hash = js_hash_to_ruby_hash(js_hash)
      flat_nested_hash(hash)
    end

    private

    def parse_hubs_js_hash(data)
      data.css('div#country_select').text.gsub(/\n|\t/, '')[/\(({container:[^\)]+).+/]; $1
    end

    def js_hash_to_ruby_hash(js_hash)
      Hash[eval(js_hash.gsub(/,'/, ", ").gsub(/':/, ": ").gsub(/\{'/, "{ "))]
    end

    def flat_nested_hash(hash)
      hash[:flags].values.inject(&:merge)
    end
  end
end
