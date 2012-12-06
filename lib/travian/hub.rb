require 'httparty'
require 'nokogiri'

module Travian
  module Hub
    extend self

    MAIN_HUB_HOST = 'http://www.travian.com'

    CODES = YAML.load_file(
      File.expand_path('../../../data/hub_codes.yml', __FILE__)
    ).with_indifferent_access

    def list
      hash = {}
      hub_hash.each {|k,v| hash[k] = {code: k, host: v, name: CODES[k][:hub] } }
      hash.with_indifferent_access
    end

    def name_of(code)
      CODES[code][:hub]
    end

    def language_of(code)
      CODES[code][:language]
    end

    private

    def hub_js_hash
      world_page = Nokogiri::HTML(HTTParty.get(MAIN_HUB_HOST).body)
      world_page.css('div#country_select').text.gsub(/\n|\t/, '').match(/\(({container:[^\)]+).+/)
      Hash.from_js($1)
    end

    def hub_hash
      hub_js_hash[:flags].values.inject(&:merge)
    end
  end
end
