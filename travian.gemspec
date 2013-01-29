# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'travian/version'

Gem::Specification.new do |gem|
  gem.name          = "travian"
  gem.version       = Travian::VERSION
  gem.authors       = ["João Soares"]
  gem.email         = ["jsoaresgeral@gmail.com"]
  gem.summary       = %q{Travian library}
  gem.description   = %q{Travian is a scraping library for the browser based game with the same name.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = `git ls-files -- bin/*`.split($/)
  gem.test_files    = `git ls-files -- spec/*`.split($/)
  gem.require_path  = "lib"

  gem.add_dependency('httparty', '~> 0.9.0')
  gem.add_dependency('nokogiri', '~> 1.5.5')

  gem.add_development_dependency("rspec", '~> 2.12')
  gem.add_development_dependency("simplecov", '~> 0.7.1')
  gem.add_development_dependency("fakeweb", '~> 1.3.0')
  gem.add_development_dependency("guard", '~> 1.5.4')
  gem.add_development_dependency("guard-rspec", '~> 2.3.0')
  gem.add_development_dependency("rb-inotify", '~> 0.8.8')
  gem.add_development_dependency("timecop", '~> 0.5.7')
end
