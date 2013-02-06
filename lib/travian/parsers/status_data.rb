module Travian
  module StatusData
    extend self
      
    def parse(data)
      codes = parse_hub_codes(data)
      server_hosts = codes.inject({}) do |hash,code|
        hash[code] = parse_server_hosts(data, code)
        hash
      end
      correct_hub_codes(server_hosts)
    end

    private

    def parse_hub_codes(data)
      data.css('td#link:nth-child(1)').map {|code| code.text.to_sym }
    end

    def parse_server_hosts(data, hub_code)
      data.css("div##{hub_code} tr:nth-child(n+2) td:nth-child(2)").map(&:text)
    end

    def correct_hub_codes(server_hosts)
      server_hosts[:net] = server_hosts[:es]
      server_hosts[:in] = server_hosts[:ine]
      server_hosts[:asia] = server_hosts[:th]
      server_hosts.select {|k,v| !k.to_s[/es|ine|th|gq/] }
    end

  end
end
