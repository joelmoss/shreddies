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

      # legacy support - can be removed once all serializers ise JsonSerializer
      alias render_as_json render
    end

    # Monkey patches Rails Module#delegate so that the `:to` argument defaults tio `:subject`.
    def self.delegate(*methods, to: :subject, prefix: nil, allow_nil: nil, private: nil)
      super(*methods, to: to, prefix: prefix, allow_nil: allow_nil, private: private)
    end

    attr_reader :subject, :options

    def initialize(subject, options)
      @subject = subject
      @options = options
    end

    def as_json
      json = {}

      methods = public_methods(false)
      if self.class.superclass.to_s.end_with?('Serializer')
        methods.concat self.class.superclass.public_instance_methods(false)
      end

      methods.uniq.excluding(:subject, :options, :as_json).map do |attr|
        json[attr] = public_send(attr)
      end

      json.deep_transform_keys { |key| key.to_s.camelize :lower }
    end
  end
end
