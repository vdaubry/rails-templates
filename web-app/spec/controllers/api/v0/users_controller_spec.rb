require 'rails_helper'

describe Api::V0::UsersController, type: :controller do

  let!(:logged_user) { create(:user) }

  describe "GET show" do
    let(:another_user) { create(:user) }

    context "not signed in" do
      before { get :show,  params: { id: another_user.to_param } }
      it { expect(response.status).to eq(401) }
    end

    context "signed in" do
      context "get info about another user" do
        before { get :show, params: { id: another_user.to_param, token: "Bearer #{logged_user.token}" } }
        it { expect(response.status).to eq(401) }
      end

      context "get info about myself" do
        before { get :show, params: { id: logged_user.to_param, token: "Bearer #{logged_user.token}" } }
        it { expect(response.status).to eq(200) }
        it { expect(parsed_response["user"]["id"]).to eq(logged_user.id) }
      end

      context "get info through 'me' alias" do
        before { get :show, params: { id: "me", token: "Bearer #{logged_user.token}" } }
        it { expect(parsed_response["user"]["id"]).to eq(logged_user.id) }
      end
    end
  end

  describe "PATCH update" do
    context "not signed in" do
      before { patch :update, params: { id: logged_user.id } }
      it { expect(response.status).to eq(401) }
    end

    context "signed in" do
      context "valid params" do
        let(:user_attributes) { {
          email: "new@bar.com",
          first_name: "foo",
          last_name: "bar",
        } }
        before do
          patch :update, params: { id: logged_user.to_param, user: user_attributes, token: "Bearer #{logged_user.token}" }
          logged_user.reload
        end
        it { expect(response.status).to eq(200) }
        it { expect(logged_user.reload.email).to eq("new@bar.com") }
        it { expect(parsed_response["user"]["id"]).to eq(logged_user.id) }
        it { expect(logged_user.email).to eq("new@bar.com") }
        it { expect(logged_user.first_name).to eq("foo") }
        it { expect(logged_user.last_name).to eq("bar") }
      end

      context "invalid params" do
        before { patch :update, params: {id: logged_user.id, user: {email: "foobar"}, token: "Bearer #{logged_user.token}" } }
        it { expect(response.status).to eq(400) }
        it { expect(parsed_response).to eq("error"=>{"code"=>"USER_UPDATE_ERROR", "messages"=>["Cannot update user"]}) }
      end

      context "try to update another user" do
        let(:another_user) { create(:user) }
        before { patch :update, params: {id: another_user.to_param, user: {forst_name: "foo"}, token: "Bearer #{logged_user.token}" } }
        it { expect(response.status).to eq(401) }
        it { expect(parsed_response).to eq({"error"=>{"code"=>"AUTHENTICATION_FAILED", "messages"=>["Cannot get info about another user"]}}) }
      end
    end
  end
end
