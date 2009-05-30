require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name     = 'dm-tokyo-adapter'
    gem.summary  = %Q{TODO}
    gem.email    = 'shane.hanna@gmail.com'
    gem.homepage = 'http://github.com/shanna/dm-tokyo-adapter'
    gem.authors  = ['Shane Hanna']
    gem.files.reject!{|f| f =~ /\.tdb$/}
    gem.add_dependency 'dm-core', '~> 0.10.0'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'dm-tokyo-cabinet-adapter'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test
