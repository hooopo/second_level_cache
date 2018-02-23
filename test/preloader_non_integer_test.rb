# frozen_string_literal: true

require "test_helper"

class PreloaderNonIntegerTest < ActiveSupport::TestCase
  def test_belongs_to_preload_caches_includes_uuid
    orders = [
      Order.create(id: "15944214-e4df-4e46-8d56-1f5864a0b90c", title: "title1", body: "body1"),
      Order.create(id: "25944214-e4df-4e46-8d56-1f5864a0b90c", title: "title2", body: "body2"),
      Order.create(id: "35944214-e4df-4e46-8d56-1f5864a0b90c", title: "title3", body: "body3")
    ]
    orders.each_with_index { |order, i| order.order_items.create(body: "order_item#{order.id}", id: "1#{i}944214-e4df-4e46-8d56-1f5864a0b90c") }

    results = nil
    assert_queries(1) do
      results = OrderItem.includes(:order).order("id ASC").to_a
    end
    assert_equal orders, results.map(&:order)
  end

  def test_belongs_to_when_read_multi_missed_from_cache_ar_will_fetch_missed_records_from_db_uuid
    orders = [
      Order.create(id: "15944214-e4df-4e46-8d56-1f5864a0b90c", title: "title1", body: "body1"),
      Order.create(id: "25944214-e4df-4e46-8d56-1f5864a0b90c", title: "title2", body: "body2"),
      Order.create(id: "35944214-e4df-4e46-8d56-1f5864a0b90c", title: "title3", body: "body3")
    ]
    orders.each_with_index { |order, i| order.order_items.create(body: "order_item#{order.id}", id: "1#{i}944214-e4df-4e46-8d56-1f5864a0b90c") }
    expired_order = orders.first
    expired_order.expire_second_level_cache

    results = nil
    assert_queries(2) do
      assert_sql(/WHERE\s\"orders\"\.\"id\" = ?/m) do
        results = OrderItem.includes(:order).order("id ASC").to_a
        assert_equal expired_order, results.first.order
      end
    end

    assert_equal orders, results.map(&:order)
  end

  def test_has_many_preloader_returns_correct_results
    order = Order.create(id: "15944214-e4df-4e46-8d56-1f5864a0b90c")
    OrderItem.create(id: "11944214-e4df-4e46-8d56-1f5864a0b90c")
    order_item = order.order_items.create(id: "12944214-e4df-4e46-8d56-1f5864a0b90c")

    assert_equal [order_item], Order.includes(:order_items).find("15944214-e4df-4e46-8d56-1f5864a0b90c").order_items
  end

  def test_has_one_preloader_returns_correct_results
    user = User.create(id: 1)
    Account.create(id: 1)
    account = user.create_account

    assert_equal account, User.includes(:account).find(1).account
  end
end
