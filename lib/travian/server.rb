require 'httparty'
require 'nokogiri'

module Travian::Server
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def fetch_list!(hub)
      return [] unless hub.respond_to? :host
      return servers_hash(hub) unless block_given?
      servers_hash(hub).each_pair do |subdomain, server|
        yield subdomain, server
      end
    end

    def parse_subdomain(host)
      host[%r{http://(\w+)\.travian\..+/}]; $1
    end

    private

    def parse_host(server_data)
      server_data.search('a.link').first['href']
    end

    def parse_name(server_data)
      server_data.search('div')[0].text.gsub(/[\s\n\t]/, '')
    end

    def parse_players(server_data)
      server_data.search('div')[1].text.gsub(/[^\d]/, '').to_i
    end

    def parse_start_date(server_data)
      Date.today - server_data.search('div')[2].text.gsub(/[^\d]/, '').to_i
    end

    def parse_version(server_data)
      server_data.text[/Travian\.Game\.version = '(.+)';/]; $1
    end

    def parse_world_id(server_data)
      server_data.text[/Travian\.Game\.worldId = '(.+)';/]; $1
    end

    def parse_speed(server_data)
      server_data.text[/Travian\.Game\.speed = (.+);/]; $1.to_i
    end

    def parse_hub_server_data(hub_server_data)
      host = parse_host(hub_server_data)
      {
        host:         host,
        code:         parse_subdomain(host),
        name:         parse_name(hub_server_data),
        start_date:   parse_start_date(hub_server_data)
      }.with_indifferent_access
    end

    def parse_server_data(server_data)
      {
        world_id: parse_world_id(server_data),
        version:  parse_version(server_data),
        speed:    parse_speed(server_data)
      }
    end

    def reject_classic_servers(servers_hash)
      servers_hash.reject {|code,server| server['code'][/tcx?\d/] }
    end

    def fetch_hub_servers_data_in_hash(hub)
      fetch_hub_server_data(hub).inject({}) do |hash,data|
        s = parse_hub_server_data(data)
        hash[s[:code]] = s
        hash
      end
    end

    def servers_hash(hub)
      return [] unless hub.respond_to? :host
      servers_hash = fetch_hub_servers_data_in_hash(hub)
      servers_hash = reject_classic_servers(servers_hash)
      servers_hash.each_pair do |subdomain, server|
        servers_hash[subdomain] = server.merge(parse_server_data(fetch_server_data(server[:host])))
      end
      servers_hash
    end

    def fetch_hub_server_data(hub)
      page = Nokogiri::HTML(HTTParty.post(hub.host + "serverLogin.php"))
      page.search('div[class~="server"]')
    end

    def fetch_server_data(server)
      page = Nokogiri::HTML(HTTParty.get(server))
      page.search('head script').last
    end
  end

  def subdomain
    Travian::Server.parse_subdomain host
  end

  extend ClassMethods
end
