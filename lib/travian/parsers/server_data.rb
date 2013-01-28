module Travian
  class ServerData

    attr_reader :server

    def initialize(data)
      @data = data
    end

    def version
      info[/Travian\.Game\.version = '(.+)';/]; $1
    end

    def world_id
      info[/Travian\.Game\.worldId = '(.+)';/]; $1
    end

    def speed
      info[/Travian\.Game\.speed = (.+);/]; $1.to_i
    end

    def restart_date
      date_str = select_world_start_info
      date_str.empty? ? nil : DateTime.strptime(self.class.sanitize_date_format(date_str), "%d.%m.%y %H:%M %:z")
    end

    private

    def info
      @data.css('head script').last.text
    end

    def select_world_start_info
      @data.css('div#worldStartInfo span.date').text
    end

    class << self

      def sanitize_date_format(date_str)
        date_str.strip.gsub(/[\(\)]|gmt\s|\.$/i, '')
      end

    end

  end

  def ServerData(data)
    ServerData.new(data)
  end
end
