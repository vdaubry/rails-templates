class BuilderGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  check_class_collision suffix: 'Builder'

  argument :attributes, type: :array, default: [], banner: 'field:type field:type'

  def create_serializer_file
    template 'builder.rb.erb', File.join('app/classes/builders', class_path, "#{file_name}_builder.rb")
  end
end
