# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hostess}
  s.version = "0.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Roos, James Adam"]
  s.date = %q{2010-11-26}
  s.default_executable = %q{hostess}
  s.email = %q{chris@chrisroos.co.uk}
  s.executables = ["hostess"]
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md", "Rakefile", "bin/hostess", "lib/hostess", "lib/hostess/options.rb", "lib/hostess/virtual_host.rb", "lib/hostess.rb"]
  s.has_rdoc = false
  s.homepage = %q{http://chrisroos.co.uk}
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["bin", "lib"]
  s.rubyforge_project = %q{hostess}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Manage simple apache virtual hosts}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end
