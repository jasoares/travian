require 'fakeweb'

pages = File.expand_path('../fakeweb_pages/', __FILE__)

FakeWeb.allow_net_connect = false

FakeWeb.register_uri(
  :get,
  'http://www.travian.com',
  :body => File.read(pages + '/www.travian.com.html'),
  :content_type => "text/html"
)

FakeWeb.register_uri(
  :post,
  'http://www.travian.pt/serverLogin.php',
  :body => File.read(pages + '/www.travian.pt_serverLogin.php.html'),
  :content_type => "text/html"
)
