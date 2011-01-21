# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{http_service}
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["palmade"]
  s.date = %q{2010-10-10}
  s.description = %q{HTTP Service}
  s.email = %q{}
  s.extra_rdoc_files = ["COPYING", "LICENSE", "README", "lib/palmade/http_service.rb", "lib/palmade/http_service/http.rb", "lib/palmade/http_service/patches.rb", "lib/palmade/http_service/patches/curb_request.rb", "lib/palmade/http_service/service.rb", "lib/palmade/http_service/utils.rb"]
  s.files = ["CHANGELOG", "COPYING", "LICENSE", "Manifest", "README", "Rakefile", "lib/palmade/http_service.rb", "lib/palmade/http_service/http.rb", "lib/palmade/http_service/patches.rb", "lib/palmade/http_service/patches/curb_request.rb", "lib/palmade/http_service/service.rb", "lib/palmade/http_service/utils.rb", "test/http_test.rb", "test/service_test.rb", "test/test_helper.rb", "http_service.gemspec"]
  s.homepage = %q{}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Http_service", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{palmade}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{HTTP Service}
  s.test_files = ["test/http_test.rb", "test/service_test.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
