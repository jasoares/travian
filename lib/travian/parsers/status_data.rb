module Travian
  module StatusData

    class << self
      
      def parse(data)
        codes = parse_hub_codes(data)
        codes.inject({}) do |hash,code|
          hash[code] = parse_server_hosts(data, code)
          hash
        end
      end

      private

      def parse_hub_codes(data)
        data.css('td#link:nth-child(1)').map {|code| code.text.to_sym }
      end

      def parse_server_hosts(data, hub_code)
        data.css("div##{hub_code} tr:nth-child(n+2) td:nth-child(2)").map(&:text)
      end

    end
  end
end
