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
  file = "#{File.expand_path('../fakeweb_pages/', __FILE__)}/#{file ? file : host.gsub(/\//, '_')}.html"
  proxy_response(host, method, file) unless File.exists?(file)
  FakeWeb.register_uri(
    method,
    "http://#{host}",
    :body => File.read(file),
    :content_type => "text/html"
  )
end

def fake_redirection(hosts, method=:get)
  redirection = {status: ['302', 'Moved Temporarily'], location: "http://#{hosts.values.first}"}
  FakeWeb.register_uri(
    method,
    "http://#{hosts.keys.first}",
    redirection
  )
  fake hosts.values.first, method
end

def unfake
  FakeWeb.clean_registry
  Travian.clear
end

def fake_hub(host)
  tld = Travian::UriHelper.tld(host)
  if %w{ co.kr co.nz }.include?(tld)
    fake_redirection_of(tld)
  else
    fake "www.travian.#{tld}"
    fake "www.travian.#{tld}/serverLogin.php", :post
  end
end

def fake_redirection_of(tld)
  case tld
  when "co.kr" then
    fake_redirection({'www.travian.co.kr' => 'www.travian.com'})
    fake_redirection({'www.travian.co.kr/serverLogin.php' => 'www.travian.com/serverLogin.php'}, :post)
  when "co.nz" then
    fake_redirection({'www.travian.co.nz' => 'www.travian.com.au'})
    fake_redirection({'www.travian.co.nz/serverLogin.php' => 'www.travian.com.au'}, :post)
  end
end
