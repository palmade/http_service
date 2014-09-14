# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'palmade/http_service/version'

Gem::Specification.new do |gem|
  gem.name        = 'http_service'
  gem.version     = Palmade::HttpService::VERSION
  gem.authors     = ['Palmade']
  gem.summary     = 'HTTP Service'

  gem.files       = `git ls-files`.split($/)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files  = gem.files.grep(%r{^(test|spec|features)/})

  gem.add_dependency 'curb'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rack'
  gem.add_development_dependency 'puppet_master'
  gem.add_development_dependency 'eventmachine'
  gem.add_development_dependency 'thin'
  gem.add_development_dependency 'yajl-ruby'
end
