# -*- encoding : utf-8 -*-
module RecordMarshal
  class << self
    # dump ActiveRecord instace without association cache.
    def dump(record)
      [
       record.class.name,
       record.instance_variable_get(:@attributes)
      ]
    end

    # load a cached record
    def load(serialized)
      record = serialized[0].constantize.allocate
      record.init_with('attributes' => serialized[1])
      record
    end
  end
end
