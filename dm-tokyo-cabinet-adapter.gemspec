# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dm-tokyo-cabinet-adapter}
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shane Hanna"]
  s.date = %q{2009-03-29}
  s.email = %q{shane.hanna@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["VERSION.yml", "README.rdoc", "lib/dm-tokyo-cabinet-adapter.rb", "lib/dm-tokyo-cabinet-adapter", "lib/dm-tokyo-cabinet-adapter/query.rb", "lib/dm-tokyo-cabinet-adapter/adapter.rb", "test/test_query.rb", "test/helper.rb", "test/test_adapter.rb", "LICENSE"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/shanna/dm-tokyo-cabinet-adapter}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
