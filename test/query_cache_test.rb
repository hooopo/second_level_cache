# frozen_string_literal: true

require "test_helper"

class QueryCacheTest < ActiveSupport::TestCase
  def setup
    User.second_level_cache_options[:unique_indexes] = [["id"], ["email"], ["name", "email"]]
    @email = "#{Time.current.to_i}@foobar.com"
    @name = "foobar"
    @attributes = { email: @email, name: @name }
  end

  def test_exec_queries
    create_user = User.create
    account = create_user.create_account
    book = create_user.books.create

    query_user = nil
    assert_sql('SELECT "books".* FROM "books" WHERE "books"."normal" = ? AND "books"."user_id" = ?') do
      query_user = User.includes(:account, :books).where(users: { id: create_user.id }).readonly.first
    end
    assert_no_queries do
      assert_equal query_user, create_user
      assert_equal query_user.account, account
      assert_equal query_user.books, [book]
    end
    assert_equal query_user.object_id, query_user.account.user.object_id
    assert_equal query_user.object_id, query_user.books.first.user.object_id
    assert query_user.readonly?
    assert_not query_user.account.readonly?

    SecondLevelCache.cache_store.clear
    query_user = assert_queries(3) do
      User.includes(:account, :namespaces).where(users: { id: create_user.id }).readonly.first
    end
    assert_equal query_user.object_id, query_user.account.user.object_id
    assert_equal query_user.object_id, query_user.books.first.user.object_id
    assert query_user.readonly?
    assert_not query_user.account.readonly?

    User.where(email: create_user.email).load  # write about email index cache
    assert_no_queries { User.where(email: create_user.email, status: create_user.status).load }
    old_status = create_user.status
    create_user.archived!
    assert_nil User.where(email: create_user.email, status: old_status).first
  end

  def test_exec_queries_cachable?
    assert User.where(id: 1).send(:exec_queries_cachable?)
    assert User.where(id: 1).includes(:account).send(:exec_queries_cachable?)
    assert_not User.where.not(id: 1).send(:exec_queries_cachable?)
    assert_not User.where(id: 1).or(User.where(id: 2)).send(:exec_queries_cachable?)
    assert_not User.where(id: 1).includes(:account).where(accounts: { id: 1 }).send(:exec_queries_cachable?)
    assert_not User.where(id: 1).eager_load(:account).send(:exec_queries_cachable?)
    assert_not User.where(id: 1).includes(:account).references(:account).send(:exec_queries_cachable?)
    assert_not User.where(id: 1).includes(:account).joins(:account).send(:exec_queries_cachable?)
    assert_not User.where(id: 1).joins(:account).send(:exec_queries_cachable?)
    assert_not User.where(id: 1).left_outer_joins(:account).send(:exec_queries_cachable?)
    assert_not User.where(id: 1).group("date(created_at)").send(:exec_queries_cachable?)
    assert_not User.where(id: 1).group("date(created_at)").having("sum(id) = ?", 1).send(:exec_queries_cachable?)
    assert_not User.where(id: 1).offset(1).send(:exec_queries_cachable?)
    assert_not User.where(id: 1).from("account").send(:exec_queries_cachable?)
    user = User.where(id: 1)
    user.skip_query_cache!
    assert_not user.send(:exec_queries_cachable?)
  end

  def test_select_values_cachable?
    assert User.send(:relation).send(:select_values_cachable?)
    assert_not User.select(:id).send(:select_values_cachable?)
  end

  def test_where_clause_cachable?
    assert_not User.where("email = #{@email}").send(:where_clause_cachable?)
    assert_not User.where.not(email: @email).send(:where_clause_cachable?)
    assert_not User.where(email: 1..10).send(:where_clause_cachable?)
    assert_not User.where(email: []).send(:where_clause_cachable?)
    assert_not User.where(name: @name).or(User.where(email: @email)).send(:where_clause_cachable?)
    assert User.where(email: @email).send(:where_clause_cachable?)
    assert User.where(@attributes).send(:where_clause_cachable?)
  end

  def test_second_level_cache_id
    # hit primary key
    assert_equal User.where(id: 1).send(:second_level_cache_id), 1

    # hit unique_indexes
    uniq_key = User.where(@attributes).load.instance_variable_get(:@second_level_cache)[:uniq_key]
    assert_equal uniq_key, User.second_level_cache_key("email=#{@email}")

    # The order of the where_values_hash should not affect the cache
    User.create(email: @email, name: @name)
    User.where(email: @email, name: @name).load  # write unique index cache
    assert_no_queries { User.where(name: @name, email: @email).load }
  end

  def test_where_values_match_cache?
    book = Book.new
    book.title = "foobar"
    assert Book.where(title: :foobar).send(:where_values_match_cache?, book)
    book.discount_percentage = 60.00
    assert Book.where(discount_percentage: "60").send(:where_values_match_cache?, book)
    book.publish_date = Time.current.to_date
    assert Book.where(publish_date: Time.current.to_date.to_s).send(:where_values_match_cache?, book)
    book.title = nil
    assert Book.where(title: nil).send(:where_values_match_cache?, book)
  end

  def test_write_second_level_cache
    uniq_key = nil

    # write cache
    # write id cache
    user = User.create(@attributes)
    assert_equal User.read_second_level_cache(user.id), user
    # write uniq_key cache
    uniq_key = User.where(@attributes).load.instance_variable_get(:@second_level_cache)[:uniq_key]
    assert_equal SecondLevelCache.cache_store.read(uniq_key), user.id

    # delete cache
    # delete id cache
    user.destroy
    assert_nil User.read_second_level_cache(user.id)
    # delete uniq_key cache
    User.where(@attributes).load
    assert_nil SecondLevelCache.cache_store.read(uniq_key)
  end
end
