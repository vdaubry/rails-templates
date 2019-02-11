require 'rails/railtie'

module ActiveModelSerializers
  class Railtie < Rails::Railtie
    # :nocov:
    generators do |app|
      Rails::Generators.configure!(app.config.generators)
      Rails::Generators.hidden_namespaces.uniq!
      require_relative 'resource_override'
    end
  end
end