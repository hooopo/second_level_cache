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
      #fix issues 19
      #fix 2.1.2 object.changed? ActiveRecord::SerializationTypeMismatch: Attribute was supposed to be a Hash, but was a String. -- "{:a=>\"t\", :b=>\"x\"}"
      #fix 2.1.4 object.changed? is true
      #fix Rails 4.2 is deprecating `serialized_attributes` without replacement to Rails 5 is deprecating `serialized_attributes` without replacement
      klass, attributes = serialized[0].constantize, serialized[1]
      if ::ActiveRecord::VERSION::STRING < '4.2.0'
        klass.serialized_attributes.each do |k, v|
          next if attributes[k].nil? || attributes[k].is_a?(String)
          if attributes[k].respond_to?(:unserialize)
            if attributes[k].serialized_value.is_a?(String)
              attributes[k] = attributes[k].serialized_value
              next
            end

            if ::ActiveRecord::VERSION::STRING >= '4.1.0' && attributes[k].coder == ActiveRecord::Coders::JSON
              attributes[k] = attributes[k].serialized_value.to_json
            else
              attributes[k] = attributes[k].serialized_value
            end
          end
        end
      else
        klass.columns.select{|t| t.cast_type.is_a?(::ActiveRecord::Type::Serialized) }.each do |c|
          name, coder = c.name, c.cast_type.coder
          next if attributes[name].nil? || attributes[name].is_a?(String)
          if coder.is_a?(ActiveRecord::Coders::YAMLColumn)
            attributes[name] = coder.dump(attributes[name]) if attributes[name].is_a?(coder.object_class)
          elsif coder == ActiveRecord::Coders::JSON
            attributes[name] = attributes[name].to_json
          end
        end
      end
      klass.instantiate(attributes)
    end

    def load_multi(serializeds)
      serializeds.map{|serialized| load(serialized)}
    end
  end
end
