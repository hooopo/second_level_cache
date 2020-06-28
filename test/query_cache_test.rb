# frozen_string_literal: true

require "test_helper"

class QueryCacheTest < ActiveSupport::TestCase
  def setup
    @old_second_level_cache_options = User.second_level_cache_options
    User.second_level_cache(@old_second_level_cache_options.merge(unique_indexes: ["id", "email", ["name", "email"]]))
    @email = "#{Time.current.to_i}@foobar.com"
    @name = "foobar"
    @attributes = { email: @email, name: @name }
  end

  def teardown
    User.second_level_cache(@old_second_level_cache_options)
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
    assert User.where(id: 1).load.send(:exec_queries_cachable?)
    assert User.where(id: 1).includes(:account).load.send(:exec_queries_cachable?)
    assert_not User.where.not(id: 1).load.send(:exec_queries_cachable?)
    assert_not User.where(id: 1).or(User.where(id: 2)).load.send(:exec_queries_cachable?)
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
    assert_not User.where("email = '#{@email}'").load.send(:where_clause_cachable?)
    assert_not User.where.not(email: @email).load.send(:where_clause_cachable?)
    assert_not User.where(email: 1..10).load.send(:where_clause_cachable?)
    assert_not User.where(name: @name).or(User.where(email: @email)).load.send(:where_clause_cachable?)
    assert_not User.where(email: [], id: []).load.send(:where_clause_cachable?)
    assert User.where(email: []).load.send(:where_clause_cachable?)
    assert User.where(email: @email).load.send(:where_clause_cachable?)
    assert User.where(@attributes).load.send(:where_clause_cachable?)
  end
end
