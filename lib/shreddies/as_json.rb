# frozen_string_literal: true

module Shreddies
  module AsJson
    module ActiveRecordBase
      def as_json(options = {})
        serializer = options.delete(:serializer) || "#{model_name}Serializer"

        case serializer
        when String, Symbol
          serializer = serializer.to_s.safe_constantize
        when Proc
          return serializer.call
        when Hash
          options = serializer
          serializer = "#{model_name}Serializer".safe_constantize
        end

        serializer ? serializer.render_as_json(self, options) : super
      end
    end

    module ActiveRecordRelation
      def as_json(options = {})
        serializer = options.delete(:serializer) || "#{model_name}Serializer"

        case serializer
        when String, Symbol
          serializer = serializer.to_s.safe_constantize
        when Proc
          return serializer.call
        when Hash
          options = serializer
          serializer = "#{model_name}Serializer".safe_constantize
        end

        serializer ? serializer.render_as_json(self, options) : super
      end
    end
  end
end
