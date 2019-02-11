module Api
  module V0
    class <%= controller_class_name %>Controller < Api::V0::BaseController
      before_action :set_<%= singular_table_name %>, only: [:show, :update, :destroy]

      #curl -H 'X-API-KEY:939f91f7d231' -H 'Authorization: Bearer azerty' -H 'Content-Type: application/json' 'http://localhost:3000/api/v0/<%= plural_table_name%>'
      def index
        <%= plural_table_name %> = <%= class_name %>.offset(offset).limit(count)

        render json: Api::V0::<%= singular_table_name.camelcase %>Serializer.render(object: <%= plural_table_name %>, include_root: true)
      end

      #curl -H 'X-API-KEY:939f91f7d231' -H 'Authorization: Bearer azerty' -H 'Content-Type: application/json' 'http://localhost:3000/api/v0/<%= plural_table_name%>/1'
      def show
        render json: Api::V0::<%= singular_table_name.camelcase %>Serializer.render(object: <%= "@#{singular_table_name}" %>, include_root: true)
      end

      #curl -H 'X-API-KEY:939f91f7d231' -X POST -H 'Authorization: Bearer azerty' -H "Content-Type: application/json" -d '{"<%= singular_table_name%>": { "foo": "bar" }}' "http://localhost:3000/api/v0/<%= plural_table_name%>"
      def create
        <%= singular_table_name%>_builder.create do |on|
          on.success do |<%= singular_table_name%>|
            render json: Api::V0::<%= singular_table_name.camelcase %>Serializer.render(object: <%= singular_table_name %>, include_root: true), status: 201
          end

          on.failure do |<%= singular_table_name%>|
            render_error(code: "CANNOT_CREATE_<%= singular_table_name.upcase%>", message: "Could not create <%= singular_table_name%> : #{<%= singular_table_name%>.errors.full_messages}", status: 400)
          end
        end
      end

      #curl -X PUT -H 'X-API-KEY:939f91f7d231' -H 'Authorization: Bearer azerty' -H 'Content-Type: application/json' -d '{"<%= singular_table_name%>": {"foo": "bar"}}' "http://localhost:3000/api/v0/<%= plural_table_name%>/1"
      def update
        <%= singular_table_name%>_builder.update(@<%= singular_table_name %>) do |on|
          on.success do |<%= singular_table_name%>|
            render json: Api::V0::<%= singular_table_name.camelcase %>Serializer.render(object: <%= singular_table_name %>, include_root: true), status: 200
          end

          on.failure do |<%= singular_table_name%>|
            render_error(code: "CANNOT_UPDATE_<%= singular_table_name.upcase%>", message: "Could not update <%= singular_table_name%> : #{<%= singular_table_name%>.errors.full_messages}", status: 400)
          end
        end
      end

      #curl -X DELETE -H 'X-API-KEY:939f91f7d231' -H 'Authorization: Bearer azerty' -H 'Content-Type: application/json' "http://localhost:3000/api/v0/<%= plural_table_name%>/1"
      def destroy
        @<%= orm_instance.destroy %>
        head :no_content
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_<%= singular_table_name %>
          @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
        end

        # Only allow a trusted parameter "white list" through.
        def <%= "#{singular_table_name}_params" %>
          <%- if attributes_names.empty? -%>
          params.fetch(:<%= singular_table_name %>, {})
          <%- else -%>
          params.require(:<%= singular_table_name %>).permit(<%= attributes_names.map { |name| ":#{name}" }.join(', ') %>)
          <%- end -%>
        end

        def <%=singular_table_name%>_builder
          @<%=singular_table_name%>_builder ||= Builders::<%= singular_table_name.camelcase %>Builder.new(params: <%= "#{singular_table_name}_params" %>)
        end
    end
  end
end