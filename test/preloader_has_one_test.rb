# frozen_string_literal: true

require "test_helper"

class PreloaderHasOneTest < ActiveSupport::TestCase
  # def test_preload_caches_includes
  #   users = User.create([
  #                         { name: "foobar1", email: "foobar1@test.com" },
  #                         { name: "foobar2", email: "foobar2@test.com" },
  #                         { name: "foobar3", email: "foobar3@test.com" }
  #                       ])
  #   namespaces = users.map { |user| user.create_namespace(name: user.name) }

  #   assert_queries(2) { User.includes(:namespace).order(id: :asc).to_a }  # Write cache
  #   assert_queries(1) do
  #     assert_equal namespaces, User.includes(:namespace).order(id: :asc).map(&:namespace)
  #   end
  # end

  # def test_when_read_multi_missed_from_cache_should_will_fetch_missed_records_from_db
  #   users = User.create([
  #                         { name: "foobar1", email: "foobar1@test.com" },
  #                         { name: "foobar2", email: "foobar2@test.com" },
  #                         { name: "foobar3", email: "foobar3@test.com" }
  #                       ])
  #   namespaces = users.map { |user| user.create_namespace(name: user.name) }
  #   assert_queries(2) { User.includes(:namespace).order(id: :asc).to_a }  # Write cache
  #   expired_namespace = namespaces.first
  #   expired_namespace.expire_second_level_cache

  #   assert_queries(2) do
  #     assert_sql(/WHERE\s\"namespaces\".\"kind\"\sIS\sNULL\sAND\s\"namespaces\"\.\"user_id\"\s=\s?/m) do
  #       results = User.includes(:namespace).order(id: :asc).to_a
  #       assert_equal namespaces, results.map(&:namespace)
  #       assert_equal expired_namespace, results.first.namespace
  #     end
  #   end
  # end

  # def test_preloader_returns_correct_records_after_modify
  #   user = User.create(name: "foobar", email: "foobar@test.com")

  #   old_namespace = user.create_namespace(name: "old")
  #   assert_queries(2) { User.includes(:namespace).order(id: :asc).to_a }  # Write cache
  #   assert_queries(1) do
  #     assert_equal old_namespace, User.includes(:namespace).first.namespace
  #   end

  #   new_namespace = user.create_namespace(name: "new")
  #   assert_queries(2) { User.includes(:namespace).order(id: :asc).to_a }  # Write cache
  #   assert_queries(1) do
  #     assert_equal new_namespace, User.includes(:namespace).first.namespace
  #   end
  # end

  # def test_preloader_caches_includes_tried_set_inverse_instance
  #   User.create(name: "foobar", email: "foobar@test.com").create_account(site: "foobar")
  #   users = User.includes(:account)
  #   assert_equal users.first.object_id, users.first.account.user.object_id
  # end

  def test_has_one_preloader_returns_correct_results
    user = User.create(id: 1)
    Account.create(id: 1)
    account = user.create_account

    assert_equal account, User.includes(:account).find(1).account
  end
end
