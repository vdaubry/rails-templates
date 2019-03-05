require 'rails_helper'

RSpec.describe Api::V0::<%= controller_class_name %>Controller, <%= type_metatag(:controller) %> do

  let(:valid_attributes) { }

  let(:invalid_attributes) { }

  let(:result) { JSON.parse(response.body) }
  let!(:user) { FactoryGirl.create(:user, token: "foobar" )}
  let!(:<%= file_name %>) { FactoryGirl.create(:<%= file_name %>)}

  describe "GET #index" do
    context "invalid token" do
      before { get :index }
      it { expect(response.status).to eq(401) }
    end

    context "valid token" do
      before { get :index, params: {token: "Bearer foobar"} }
      it { expect(response.status).to eq(200) }
      it { expect(result).to eq({'<%= file_name.pluralize %>' => [{}]}) }
    end
  end

  describe "GET #show" do
    context "invalid token" do
      before { get :show, params: {id: <%= file_name %>.to_param} }
      it { expect(response.status).to eq(401) }
    end

    context "valid token" do
      before { get :show, params: {id: <%= file_name %>.to_param, token: "Bearer foobar"} }
      it { expect(response.status).to eq(200) }
      it { expect(result).to eq({'<%= file_name %>' => {}}) }
    end
  end

  describe "POST create" do
    context "invalid token" do
      before { post :create, params: { <%= file_name %>: valid_attributes, format: :json } }
      it { expect(response.status).to eq(401) }
    end

    context "valid token" do
      context "valid attributes" do
        before { post :create, params: { <%= file_name %>: valid_attributes, token: "Bearer foobar", format: :json } }
        it { expect(response.status).to eq(201) }
        it { expect(result["<%= file_name %>"]).to_not be_nil }
        it { expect(<%= file_name.camelcase %>.count).to eq(2) }
      end
    end
  end

  describe "PATCH update" do
    context "invalid token" do
      before { put :update, params: { id: <%= file_name %>.to_param, <%= file_name %>: valid_attributes, format: :json } }
      it { expect(response.status).to eq(401) }
    end

    context "valid token" do
      context "valid attributes" do
        before { put :update, params: { id: <%= file_name %>.to_param, <%= file_name %>: valid_attributes, token: "Bearer foobar", format: :json } }
        it { expect(response.status).to eq(200) }
        it { expect(result["<%= file_name %>"]).to_not be_nil }
        it { expect(<%= file_name.camelcase %>.count).to eq(1) }
      end
    end
  end

  describe "DELETE destroy" do
    context "invalid token" do
      before { delete :destroy, params: { id: <%= file_name %>.to_param, format: :json} }
      it { expect(response.status).to eq(401) }
    end

    context "valid token" do
      before { delete :destroy, params: {id: <%= file_name %>.to_param, token: "Bearer foobar", format: :json} }
      it { expect(response.status).to eq(204) }
      it { expect(<%= file_name.camelcase %>.count).to eq(0) }
    end
  end
end
