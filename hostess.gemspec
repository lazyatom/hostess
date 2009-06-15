# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hostess}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Roos, James Adam"]
  s.date = %q{2009-06-15}
  s.default_executable = %q{hostess}
  s.email = %q{chris@chrisroos.co.uk}
  s.executables = ["hostess"]
  s.extra_rdoc_files = ["README"]
  s.files = ["README", "Rakefile", "bin/hostess"]
  s.homepage = %q{http://chrisroos.co.uk}
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["bin"]
  s.rubyforge_project = %q{hostess}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Manage simple apache virtual hosts}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
