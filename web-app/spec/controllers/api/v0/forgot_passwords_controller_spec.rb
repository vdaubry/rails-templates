require 'rails_helper'
require 'securerandom'

RSpec.describe Api::V0::ForgotPasswordsController, type: :controller do
  describe "POST create" do
    context "email exists" do
      before { SecureRandom.stub(:uuid) { "foobar" } }
      let!(:user) { create(:user, email: "foo@bar.com") }
      let(:valid_params) { {email: user.email} }
      before { post :create, params: valid_params, format: :json }
      it { expect(response.status).to eq(200) }
      it { expect($redis.get("1job1passion:users:foobar:reset_password_token")).to_not eq(user.id) }
    end

    context "email not found" do
      let(:valid_params) { {email: "foo@bar.com"} }
      before { post :create, params: valid_params }
      it { expect(parsed_response).to eq({"error"=>{"code"=>"EMAIL_UNKNOWN", "messages"=>["Cet email ne correspond à aucun utilisateur connu"]}}) }
    end
  end
end
