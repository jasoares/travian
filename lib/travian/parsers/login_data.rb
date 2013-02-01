module Travian
  module LoginData
    extend UriHelper::ClassMethods
    extend self

    def parse(data)
      split_servers(data).inject({}) do |hash, login_data|
        host = parse_host(login_data)
        name = parse_name(login_data)
        start_date = parse_start_date(login_data)
        players = parse_players(login_data)
        key = server_code(host).to_sym
        hash[key] = [host, name, start_date, players]
        hash
      end
    end

    def parse_host(data)
      data.css('a.link').first['href']
    end

    def parse_name(data)
      data.css('div')[0].text.strip
    end

    def parse_start_date(data)
      days_ago = data.css('div')[2].text.gsub(/[^\d]/, '').to_i
      (Date.today - days_ago).to_datetime
    end

    def parse_players(data)
      data.css('div')[1].text.gsub(/[^\d]/, '').to_i
    end

    def split_servers(data)
      data.css('div[class~="server"]')
    end

  end
end
