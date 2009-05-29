require 'rubygems'
require 'test/unit'
require 'shoulda'

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'dm-tokyo-cabinet-adapter'

class Test::Unit::TestCase
end

DataMapper.setup(:default, {
  :adapter  => 'tokyo_cabinet',
  :database => 'tc',
  :path     => File.dirname(__FILE__)
})

class Test::Unit::TestCase
  include Extlib::Hook

  # after :teardown do
  def teardown
    descendants = DataMapper::Model.descendants.dup.to_a
    while model = descendants.shift
      descendants.concat(model.descendants) if model.respond_to?(:descendants)
      Object.send(:remove_const, model.name.to_sym)
      DataMapper::Model.descendants.delete(model)
    end
  end
end

