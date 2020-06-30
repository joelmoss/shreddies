# frozen_string_literal: true

module Shreddies
  module AsJson
    module ActiveRecordBase
      def as_json(options = {})
        serializer = options.delete(:serializer) || "#{model_name}Serializer"

        if serializer.is_a?(String) || serializer.is_a?(Symbol)
          serializer.to_s.constantize.render self, options
        else
          serializer.render self, options
        end
      rescue NameError
        super
      end
    end

    module ActiveRecordRelation
      def as_json(options = {})
        serializer = options.delete(:serializer) || "#{model_name}Serializer"

        if serializer.is_a?(String) || serializer.is_a?(Symbol)
          serializer.to_s.constantize.render self, options
        else
          serializer.render self, options
        end
      rescue NameError
        super
      end
    end
  end
end
