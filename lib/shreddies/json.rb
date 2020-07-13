# frozen_string_literal: true

module Shreddies
  class Json
    class << self
      # Render a subject as json, where `subject` is a single object (usually a Rails model), or an
      # array/collection of objects.
      #
      # A Hash of options can be given as the second argument:
      #   - index_by - Key the returned array by the value, transforming it from an array to a hash.
      #
      def render(subject, options = {})
        index_by = options.delete(:index_by)

        if subject.is_a?(Array) || subject.is_a?(ActiveRecord::Relation)
          if index_by
            mapped = {}
            subject.each do |x|
              mapped[x[index_by]] = new(x, options)
            end
          else
            mapped = subject.map { |x| new(x, options) }
          end

          mapped.as_json
        else
          new(subject, options).as_json
        end
      end

      alias render_as_json render
    end

    # Monkey patches Rails Module#delegate so that the `:to` argument defaults to `:subject`.
    def self.delegate(*methods, to: :subject, prefix: nil, allow_nil: nil, private: nil)
      super(*methods, to: to, prefix: prefix, allow_nil: allow_nil, private: private)
    end

    attr_reader :subject, :options

    def initialize(subject, options)
      @subject = subject
      @options = options
    end

    # Travel through the ancestors that are serializers (class name ends with "Serializer"), and
    # call all public instance methods, returning a hash.
    def as_json
      json = {}
      methods = Set[]

      self.class.ancestors.each do |ancestor|
        if ancestor.to_s.end_with?('Serializer')
          methods.merge ancestor.public_instance_methods(false)
        end
      end

      methods.map do |attr|
        json[attr.to_s.camelize :lower] = public_send(attr)
      end

      json.deep_transform_keys { |key| key.to_s.camelize :lower }
    end
  end
end
