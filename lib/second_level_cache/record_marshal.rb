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
      if ::ActiveRecord::VERSION::STRING > '4.1.8' && ::ActiveRecord::VERSION::MAJOR < 5
        #fix issues 19
        #fix 2.1.2 object.changed? ActiveRecord::SerializationTypeMismatch: Attribute was supposed to be a Hash, but was a String. -- "{:a=>\"t\", :b=>\"x\"}"
        #fix 2.1.4 object.changed? is true
        serialized[0].constantize.serialized_attributes.each do |k, v|
          next if serialized[1][k].nil?
          serialized[1][k] = v.dump(serialized[1][k]) if serialized[1][k].is_a?(v.object_class)
        end
      end
      serialized[0].constantize.instantiate(serialized[1])
    end

    def load_multi(serializeds)
      serializeds.map{|serialized| load(serialized)}
    end
  end
end
