require 'fakeweb'

FakeWeb.allow_net_connect = false

def FakeWeb.allow
  FakeWeb.allow_net_connect = true
  v = yield
  FakeWeb.allow_net_connect = false
  v
end

def proxy_response(host, method, file)
  File.open(file, 'w') do |f|
    response = FakeWeb.allow { HTTParty.send(method, "http://#{host}") }
    f.write(response.body)
  end
end

def fake(host, method=:get, file=nil)
  file ||= "#{File.expand_path('../fakeweb_pages/', __FILE__)}/#{host.gsub(/\//, '_')}.html"
  proxy_response(host, method, file) unless File.exists?(file)
  FakeWeb.register_uri(
    method,
    "http://#{host}",
    :body => File.read(file),
    :content_type => "text/html"
  )
end

def fake_redirection(hosts)
  redirection = {status: ['302', 'Moved Temporarily'], location: "http://#{hosts.values.first}"}
  FakeWeb.register_uri(
    :get,
    "http://#{hosts.keys.first}",
    redirection
  )
end

def unfake
  FakeWeb.clean_registry
end
