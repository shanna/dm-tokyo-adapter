require 'rubygems'
require 'test/unit'
require 'shoulda'

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'dm-tokyo-adapter'

class Test::Unit::TestCase
end

DataMapper::Logger.new(STDOUT, :debug) if $VERBOSE
DataMapper.setup(:default, {
  :adapter  => 'tokyo_cabinet',
  :database => 'tc',
  :path     => File.dirname(__FILE__)
})

class Test::Unit::TestCase
  include Extlib::Hook

  # after :teardown do
  def teardown
    descendants = DataMapper::Model.descendants.to_a
    while model = descendants.shift
      descendants.concat(model.descendants.to_a - [ model ])

      parts = model.name.split('::')
      constant_name = parts.pop.to_sym
      base = parts.empty? ? Object : Object.full_const_get(parts.join('::'))

      if base.const_defined?(constant_name)
        base.send(:remove_const, constant_name)
      end

      DataMapper::Model.descendants.delete(model)
    end
  end
end

