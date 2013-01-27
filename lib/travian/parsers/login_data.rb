module Travian
  module LoginData
    extend self

    def split_servers(data)
      data.css('div[class~="server"]')
    end

    def parse(data)
      host = parse_host(data)
      name = parse_name(data)
      start_date = parse_start_date(data)
      players = parse_players(data)
      [host, name, start_date, players]
    end

    def parse_host(data)
      data.search('a.link').first['href']

    end

    def parse_name(data)
      data.search('div')[0].text.strip
    end

    def parse_players(data)
      data.search('div')[1].text.gsub(/[^\d]/, '').to_i
    end

    def parse_start_date(data)
      days_ago = data.search('div')[2].text.gsub(/[^\d]/, '').to_i
      (Date.today - days_ago).to_datetime
    end

  end
end
