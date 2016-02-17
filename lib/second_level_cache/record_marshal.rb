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
      #fix issues 19
      #fix 2.1.2 object.changed? ActiveRecord::SerializationTypeMismatch: Attribute was supposed to be a Hash, but was a String. -- "{:a=>\"t\", :b=>\"x\"}"
      #fix 2.1.4 object.changed? is true
      #fix Rails 4.2 is deprecating `serialized_attributes` without replacement to Rails 5 is deprecating `serialized_attributes` without replacement
      klass, attributes = serialized[0].constantize, serialized[1]

      # for ActiveRecord 5.0.0
      klass.columns.each do |c|
        name = c.name
        cast_type = klass.attribute_types[name]
        next if !cast_type.is_a?(::ActiveRecord::Type::Serialized)
        coder = cast_type.coder
        next if attributes[name].nil? || attributes[name].is_a?(String)
        if coder.is_a?(::ActiveRecord::Coders::YAMLColumn)
          attributes[name] = coder.dump(attributes[name]) if attributes[name].is_a?(coder.object_class)
        elsif coder == ::ActiveRecord::Coders::JSON
          attributes[name] = attributes[name].to_json
        end
      end

      klass.instantiate(attributes)
    end

    def load_multi(serializeds)
      serializeds.map{|serialized| load(serialized)}
    end
  end
end
