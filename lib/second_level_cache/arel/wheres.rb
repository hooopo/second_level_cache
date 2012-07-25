# -*- encoding : utf-8 -*-
module SecondLevelCache
  module Arel
    class Wheres
      attr_reader :where_values

      def initialize(where_values)
        @where_values = where_values
      end

      # Determine whether all conditions is equality, for example:
      #
      #     Article.where("user_id = 1").where(:status => 1).find(1)
      def all_equality?
        where_values.all?{|where_value| where_value.is_a?(::Arel::Nodes::Equality)}
      end

      # Extract conditions to pairs, for checking whether cache match the conditions.
      def extract_pairs
        where_values.map do |where_value|
          if where_value.is_a?(String)
            left, right = where_value.split(/\s*=\s*/, 2)
            right = right.to_i
          else
            left, right = where_value.left.name, where_value.right
          end
          {
            :left  => left,
            :right => right
          }
        end
      end
    end
  end
end
