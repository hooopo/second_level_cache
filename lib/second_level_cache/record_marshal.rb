# -*- encoding : utf-8 -*-
module RecordMarshal
  class << self
    # dump ActiveRecord instace with only attributes.
    # ["User",
    #  {"id"=>30,
    #  "email"=>"dddssddd@gmail.com",
    #  "created_at"=>2012-07-25 18:25:57 UTC
    #  }
    # ]

    def dump(record)
      [
       record.class.name,
       record.attributes
      ]
    end

    # load a cached record
    def load(serialized)
      return unless serialized
      record = serialized[0].constantize.allocate
      record.init_with('attributes' => serialized[1])
      record
    end
  end
end
