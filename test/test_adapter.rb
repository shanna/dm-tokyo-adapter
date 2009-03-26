require File.join(File.dirname(__FILE__), 'helper')

class AdapterTest < Test::Unit::TestCase
  context 'Resource' do
    setup do
      class ::User
        include DataMapper::Resource
        property :id, Serial
        property :name, String
        property :age, Integer
      end

      @user = User.create(:name => 'Joe', :age => 22)
    end

    teardown do
      # Why doesn't DM::Resource#destroy exist?
      repository = DataMapper.repository(:default)
      repository.adapter.delete(
        DataMapper::Query.new(repository, ::User, {})
      )
    end

    should 'assign id to attributes' do
      item = User.create
      assert_kind_of User, item
      assert_not_nil item.id
    end

    should 'get an item' do
      assert_equal @user, User.get(@user.id)
    end

    should 'get items' do
      assert_equal 1, User.all.size
    end

    should 'destroy item' do
      assert @user.destroy
      assert_equal 0, User.all.size
    end
  end
end
