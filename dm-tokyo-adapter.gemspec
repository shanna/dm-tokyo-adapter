# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-tokyo-adapter}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shane Hanna"]
  s.date = %q{2009-05-30}
  s.email = %q{shane.hanna@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "lib/dm-tokyo-adapter.rb",
    "test/helper.rb",
    "test/test_adapter.rb",
    "test/test_query.rb"
  ]
  s.homepage = %q{http://github.com/shanna/dm-tokyo-adapter}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{TODO}
  s.test_files = [
    "test/helper.rb",
    "test/test_adapter.rb",
    "test/test_query.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<dm-core>, ["~> 0.10.0"])
    else
      s.add_dependency(%q<dm-core>, ["~> 0.10.0"])
    end
  else
    s.add_dependency(%q<dm-core>, ["~> 0.10.0"])
  end
end
