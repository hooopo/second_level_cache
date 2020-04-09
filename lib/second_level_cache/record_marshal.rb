# frozen_string_literal: true

module RecordMarshal
  class << self
    # dump ActiveRecord instance with only attributes before type cast.
    def dump(record)
      [record.class.name, record.attributes_before_type_cast]
    end

    # load a cached record
    def load(serialized, &block)
      return unless serialized

      serialized[0].constantize.instantiate(serialized[1], &block)
    end

    # load multi cached records
    def load_multi(serializeds, &block)
      serializeds.map { |serialized| load(serialized, &block) }
    end
  end
end
