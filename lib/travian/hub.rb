require 'httparty'
require 'nokogiri'

module Travian::Hub
  def self.included(base)
    base.extend(ClassMethods)
  end

  CODES = YAML.load_file(
    File.expand_path('../../../data/hub_codes.yml', __FILE__)
  ).with_indifferent_access

  MAIN_HUB_HOST = 'http://www.travian.com'

  module ClassMethods

    def fetch_list!
      return hubs_hash unless block_given?
      hubs_hash.each_pair do |k,v|
        yield k, v
      end
    end

    private

    def name_of(code)
      CODES[code][:hub]
    end

    def language_of(code)
      CODES[code][:language]
    end

    def fetch_data
      world_page = Nokogiri::HTML(HTTParty.get(MAIN_HUB_HOST).body)
      world_page.css('div#country_select').text.gsub(/\n|\t/, '')[/\(({container:[^\)]+).+/]; $1
    end

    def hub_js_hash
      Hash.from_js(fetch_data)
    end

    def hubs_hash
      hash = {}.with_indifferent_access
      hub_js_hash[:flags].values.inject(&:merge).each do |k,v|
        begin
          HTTParty.post("#{v}serverLogin.php", limit: 1)
          hash[k] = { code: k, host: v, name: name_of(k) } if HTTParty.get(v)
        rescue HTTParty::RedirectionTooDeep
        end
      end
      hash
    end
  end

  extend ClassMethods
end
