# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-tokyo-cabinet-adapter}
  s.version = "0.1.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shane Hanna"]
  s.date = %q{2009-05-10}
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
    "lib/dm-tokyo-cabinet-adapter.rb",
    "lib/dm-tokyo-cabinet-adapter/adapter.rb",
    "lib/dm-tokyo-cabinet-adapter/query.rb",
    "test/helper.rb",
    "test/test_adapter.rb",
    "test/test_query.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/shanna/dm-tokyo-cabinet-adapter}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}
  s.test_files = [
    "test/helper.rb",
    "test/test_adapter.rb",
    "test/test_query.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
