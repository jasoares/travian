require 'fakeweb'

pages = File.expand_path('../fakeweb_pages/', __FILE__)

FakeWeb.allow_net_connect = false

hub_faker = lambda do |hosts|
  hosts.each do |host|
    FakeWeb.register_uri(
      :get,
      "http://#{host}/",
      :body => File.read(pages + "/#{host}.html"),
      :content_type => "text/html"
    )
  end
end

shared_context 'online' do
  before(:all) { FakeWeb.allow_net_connect = true }
  after(:all) { FakeWeb.allow_net_connect = false }
end

shared_context 'fake main hub' do
  before(:all) do
    FakeWeb.register_uri(
      :get,
      'http://www.travian.com',
      :body => File.read(pages + '/www.travian.com.html'),
      :content_type => "text/html"
    )
  end

  after(:all) { FakeWeb.clean_registry }
end


shared_context 'fake pt serverLogin' do
  before(:all) do
    FakeWeb.register_uri(
      :post,
      'http://www.travian.pt/serverLogin.php',
      :body => File.read(pages + '/www.travian.pt_serverLogin.php.html'),
      :content_type => "text/html"
    )
  end
  after(:all) { FakeWeb.clean_registry }
end

shared_context 'fake tx3.travian.pt' do
  before(:all) do
    FakeWeb.register_uri(
      :get,
      'http://tx3.travian.pt/',
      :body => File.read(pages + '/tx3.travian.pt.html'),
      :content_type => "text/html"
    )
  end
  after(:all) { FakeWeb.clean_registry }
end

shared_context 'fake portuguese hub and servers' do
  include_context 'fake pt serverLogin'
  before(:all) do
    pt_hub_hosts = %w{
      ts1.travian.pt ts10.travian.pt ts2.travian.pt ts3.travian.pt ts4.travian.pt
      ts5.travian.pt ts6.travian.pt ts7.travian.pt tx3.travian.pt tc9.travian.pt
    }
    hub_faker.call(pt_hub_hosts)
  end
  after(:all) { FakeWeb.clean_registry }
end

shared_context 'fake czech hub and servers' do
  before(:all) do
    cz_hub_hosts = %w{
      www.travian.cz ts1.travian.cz ts3.travian.cz ts4.travian.cz ts5.travian.cz ts7.travian.cz tx3.travian.cz
    }
    hub_faker.call(cz_hub_hosts)
    FakeWeb.register_uri(
      :post,
      'http://www.travian.cz/serverLogin.php',
      :body => File.read(pages + '/www.travian.cz_serverLogin.php.html'),
      :content_type => "text/html"
    )
  end
  after(:all) { FakeWeb.clean_registry }
end
