# frozen_string_literal: true

module Shreddies
  class Json
    class << self
      # Render a subject as json, where `subject` is a single object (usually a Rails model), or an
      # array/collection of objects.
      #
      # If subject is an array/collection then it will look for a `Collection` module prepend it to
      # the `module` option.
      #
      # A Hash of options can be given as the second argument:
      #   - index_by - Key the returned array by the value, transforming it from an array to a hash.
      #   - module   - A Symbol or String of a local module to include. Or an array of several
      #                modules, where each will be mixed in in order. Use this to mix in groups of
      #                attributes. Eg. `ArticleSerializer.render(data, module: :WithBody)`.
      #
      def render(subject, options = {})
        index_by = options.delete(:index_by)

        if subject.is_a?(Array) || subject.is_a?(ActiveRecord::Relation)
          collection_options = options.merge(from_collection: true)

          if index_by
            mapped = {}
            subject.each do |x|
              mapped[x[index_by]] = new(x, collection_options)
            end
          else
            mapped = subject.map { |x| new(x, collection_options) }
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

    def initialize(subject, opts = {})
      @subject = subject.is_a?(Hash) ? OpenStruct.new(subject) : subject
      @options = { transform_keys: true }.merge(opts)

      extend_with_modules
    end

    # Travel through the ancestors that are serializers (class name ends with "Serializer"), and
    # call all public instance methods, returning a hash.
    def as_json
      output = {}.with_indifferent_access
      methods = Set.new(public_methods(false))

      self.class.ancestors.each do |ancestor|
        if ancestor.to_s.end_with?('Serializer')
          methods.merge ancestor.public_instance_methods(false)
        end
      end

      # Filter out methods using the `only` or `except` options.
      if @options[:only]
        @options[:only] = Array(@options[:only])
        methods = methods.select { |x| @options[:only].include? x }
      elsif @options[:except]
        methods = methods.excluding(@options[:except])
      end

      methods.map do |attr|
        res = public_send(attr)
        if res.is_a?(ActiveRecord::Relation) || res.is_a?(ActiveRecord::Base)
          res = res.as_json(transform_keys: @options[:transform_keys])
        end

        output[attr] = res
      end

      output = before_render(output)

      return output unless @options[:transform_keys]

      output.deep_transform_keys { |key| key.to_s.camelize :lower }
    end

    private

    def before_render(output)
      output
    end

    def extend_with_modules
      self.class.ancestors.reverse.each do |ancestor|
        next unless ancestor.to_s.end_with?('Serializer')

        # Extend with Collection module if it exists, and a collection is being rendered. Otherwise,
        # extend with the Single module if that exists.
        if @options[:from_collection]
          (collection_mod = "#{ancestor}::Collection".safe_constantize) && extend(collection_mod)
        else
          (single_mod = "#{ancestor}::Single".safe_constantize) && extend(single_mod)
        end
      end

      # Extend with the :module option if given.
      if @options[:module]
        Array(@options[:module]).each do |m|
          extend m.is_a?(Module) ? m : "#{self.class}::#{m}".constantize
        end
      end
    end
  end
end
