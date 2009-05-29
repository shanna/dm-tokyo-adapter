require File.join(File.dirname(__FILE__), 'helper')

class QueryTest < Test::Unit::TestCase
  context 'Resource' do
    setup do
      class ::User
        include DataMapper::Resource
        property :id, Serial
        property :name, String
        property :age, Integer
      end

      @joe   = User.create(:name => 'Joe',  :age => 11)
      @jack  = User.create(:name => 'Jack', :age => 22)
      @john  = User.create(:name => 'John', :age => 33)
    end

    teardown do
      User.all.destroy
    end

    should 'get items' do
      assert_equal 3, User.all.size
    end

    should 'get items with sring conditions' do
      User.create(:name => 'John', :age => 44)
      assert_equal 2, User.all(:name => 'John').size
    end

    should 'get items with integer equality conditions' do
      User.create(:name => 'Fred', :age => 33)
      assert_equal 2, User.all(:age => 33).size
    end

    should 'get items with integer range conditions' do
      User.create(:name => 'Fred', :age => 33)
      assert_equal 3, User.all(:age.gte => 22, :age.lte => 34).size
    end

    should 'order items by string' do
      users = [@jack, @joe, @john]
      assert_equal users, User.all(:order => [:name.asc])
      assert_equal users.reverse, User.all(:order => [:name.desc])
    end

    should 'order items by integer' do
      users = [@joe, @jack, @john]
      assert_equal users, User.all(:order => [:age.asc])
      assert_equal users.reverse, User.all(:order => [:age.desc])
    end

    should 'limit items' do
      assert_equal 2, User.all(:limit => 2).size
    end
  end
end # QueryTest

