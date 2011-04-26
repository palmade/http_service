require 'rubygems'
gem 'echoe'
require 'echoe'

Echoe.new("http_service") do |p|
  p.author = "palmade"
  p.project = "palmade"
  p.summary = "HTTP Service"

  p.dependencies = [ ]

  p.need_tar_gz = false
  p.need_tgz = true

  p.clean_pattern += [ "pkg", "lib/*.bundle", "*.gem", ".config" ]
  p.rdoc_pattern = [ 'README', 'LICENSE', 'COPYING', 'lib/**/*.rb', 'doc/**/*.rdoc' ]
end

gem 'rspec', '>= 2.5.0'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task :default => :spec
