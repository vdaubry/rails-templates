class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.string_enum(enum_hash)
    enum_name = enum_hash.keys.first
    enum_values = enum_hash[enum_name].freeze
    enum_values.each do |value|
      #def foo?
      #  status==foo
      #end
      define_method("#{value}?") { send(enum_name) == value.upcase.to_s }

      #def foo!
      #  status=foo
      #end
      define_method("#{value}!") { send("#{enum_name}=", value.upcase.to_s) }

      #class::Foo = "FOO"
      const_set(value.to_s.camelcase, value.to_s.underscore.upcase) unless const_defined?(value.to_s.camelcase, false)

      #def self.statuses
      # [:foo, :bar]
      #end
      define_singleton_method(enum_name.to_s.pluralize) { enum_values }

      #def self.foo
      # where(status: "FOO")
      #end
      define_singleton_method(value.to_s) { where(enum_name => value.upcase.to_s) }
    end
    define_singleton_method("#{enum_name}_values") { enum_values.map { |v| v.to_s.upcase } }
  end
end
