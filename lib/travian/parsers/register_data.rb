module Travian
  module RegisterData
    extend UriHelper::ClassMethods
    extend self

    def parse(data, hub)
      select_restarting_servers(data).map do |server|
        find_restarting_host(server, hub)
      end
    end

    def parse_name(data)
      data.css('div.name').text.strip
    end

    def find_restarting_host(server, hub)
      name = parse_name(server)
      server_code = possible_codes(name).find do |code|
        Server.new("#{code}.travian.#{hub.tld}").restarting?
      end
      server_code ? "#{server_code}.travian.#{hub.tld}" : hub.host
    end

    def select_restarting_servers(data)
      data.css('div[class~="serverPreRegister"]')
    end

    def possible_codes(name)
      n = name[/\d+/]
      has_x = name[/x/]
      is_speed_number = [3,4,5,8,10,15,30].include?(n.to_i)
      codes = []
      if n
        codes += ["tx#{n}", "tcx#{n}"] if has_x and is_speed_number
        codes += ["ts#{n}", "tc#{n}"]
        codes += ["tx#{n}", "tcx#{n}"] if !has_x and is_speed_number
      else
        codes = [name.gsub(/\s+/, '').downcase]
      end
      codes
    end
  end
end
