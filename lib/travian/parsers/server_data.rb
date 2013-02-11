module Travian
  module ServerData
    extend self

    def parse(data)
      version = parse_version(data)
      world_id = parse_world_id(data)
      speed = parse_speed(data)
      restart_date = parse_restart_date(data)
      server_id = parse_server_id(data)
      [version, world_id, speed, restart_date, server_id]
    end

    def parse_version(data)
      select_info(data)[/Travian\.Game\.version = '(.+)';/]; $1
    end

    def parse_world_id(data)
      select_info(data)[/Travian\.Game\.worldId = '(.+)';/]; $1
    end

    def parse_speed(data)
      select_info(data)[/Travian\.Game\.speed = (.+);/]; $1.to_i
    end

    def parse_restart_date(data)
      date_str = select_world_start_info(data)
      date_str.empty? ? nil : DateTime.strptime(sanitize_date_format(date_str), "%d.%m.%y %H:%M %:z")
    end

    def parse_server_id(data)
      links = data.css('div#side_navi li:nth-child(3) a')
      return nil if links.empty?
      uri = URI(links.first['href'])
      uri.query[/server=(\w+)$/]; $1
    end

    private

    def select_info(data)
      script = data.css('head script').last
      script ? script.text : ""
    end

    def select_world_start_info(data)
      data.css('div#worldStartInfo span.date').text
    end

    def sanitize_date_format(date_str)
      date_str.strip.gsub(/[^\d\.\s:+-]|\.$/i, '').gsub(/\s+/, ' ')
    end

  end
end
