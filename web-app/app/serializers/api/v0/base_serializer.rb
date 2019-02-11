module Api
  module V0
    class BaseSerializer
      def initialize(object:, info: nil, options: {})
        @object = object
        @info = info
        @options = options
      end

      def to_json(include_root: true)
        object_json = include_root ? {self.class.root_key => json} : json
        object_json.merge!({result: {info: info}}) if info
        object_json
      end

      def json
        {
          id: object.id
        }
      end

      private
      attr_reader :object, :info, :options

      class << self
        def render(object:, include_root: false, options: {})
          return nil if object.nil?

          if is_collection?(object)
            output = render_collection(object, options)
            if include_root
              {
                root_key.pluralize => output
              }
            else
              output
            end
          else
            self.new(object: object, options: options).to_json(include_root: include_root)
          end
        end

        def render_collection(objects, options)
          objects.map do |object|
            self.new(object: object, options: options).to_json(include_root: false)
          end
        end

        def root_key
          self.name.demodulize.split("Serializer").first.underscore
        end

        def is_collection?(object)
          object.is_a?(ActiveRecord::Relation) ||
            object.is_a?(Array)
        end
      end
    end
  end
end
