class Rails::SerializerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  check_class_collision suffix: 'Serializer'

  argument :attributes, type: :array, default: [], banner: 'field:type field:type'

  def create_serializer_file
    template 'serializer.rb.erb', File.join('app/serializers/api/v0', class_path, "#{file_name}_serializer.rb")
  end

  def run_other_generators
    generate "builder #{file_name}"
  end

  private

  def attributes_names
    [:id, :created_at, :updated_at] + attributes.reject(&:reference?).map! { |a| a.name.to_sym }
  end
end
