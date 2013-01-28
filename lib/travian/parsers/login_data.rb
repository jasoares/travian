module Travian
  class LoginData

    def initialize(data)
      raise ArgumentError, "Data Missing" if data.nil?
      @data = data
    end

    def host
      @data.css('a.link').first['href']
    end

    def name
      @data.css('div')[0].text.strip
    end

    def players
      @data.css('div')[1].text.gsub(/[^\d]/, '').to_i
    end

    def start_date
      days_ago = @data.css('div')[2].text.gsub(/[^\d]/, '').to_i
      (Date.today - days_ago).to_datetime
    end

    def to_array
      [host, name, start_date, players]
    end

    class << self

      def split_servers(data)
        data.css('div[class~="server"]')
      end

    end

  end

  def LoginData(data)
    LoginData.new(data)
  end
end
