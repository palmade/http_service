# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'http_service'
  s.version     = '0.1'
  s.authors     = ['Palmade']
  s.summary     = 'HTTP Service'
  s.description = 'Master of Puppets'

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths    = ['lib']
  s.extra_rdoc_files = ['README', 'CHANGELOG', 'COPYING', 'LICENSE']
  s.rdoc_options     = ['--line-numbers', '--inline-source', '--title', 'http_service', '--main', 'README']

  s.add_development_dependency 'rake'
end

