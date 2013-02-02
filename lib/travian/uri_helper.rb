module Travian
  module UriHelper

    def tld
      UriHelper.tld(host)
    end

    def subdomain
      UriHelper.subdomain(host)
    end

    def hub_code
      UriHelper.hub_code(host)
    end

    def server_code
      UriHelper.server_code(host)
    end

    module ClassMethods

      def tld(host)
        host[/travian\w*\.(\w+(?:\.\w+)?)\/?$/]; $1
      end

      def subdomain(host)
        host[/(\w+)\.travian/]; $1
      end

      def hub_code(host)
        tld = tld(host)
        return 'cn' if tld == 'cc'
        return 'arabia' if tld == 'com' && subdomain(host).include?('arabia')
        tld[/\w+$/]
      end

      def server_code(host)
        server_code = subdomain(host)
        server_code == 'www' || server_code == 'arabia' ? nil : server_code
      end

    end

    extend ClassMethods
  end
end
