require File.join(File.dirname(__FILE__), 'helper')

class AdapterTest < Test::Unit::TestCase
  context DataMapper::Adapters::TokyoTyrantAdapter do
    should 'behave like DM::A::TokyoCabinetAdapter'
  end
end
