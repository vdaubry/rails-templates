require 'rails_helper'

<% module_namespacing do -%>
RSpec.describe <%= class_name %>, <%= type_metatag(:model) %> do
  context "create" do
    it { expect(FactoryGirl.build(:<%= file_name %>).save).to be true }
  end
end
