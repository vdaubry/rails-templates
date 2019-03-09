require 'rails_helper'

RSpec.describe Api::V0::LoginController, type: :controller do

  let(:valid_credentials) { {email: "foo@bar.com", password: "foobar"} }
  let(:invalid_credentials) { {email: "foo@bar.com", password: "toto"} }

  describe 'POST create' do
    context "user exists" do
      let!(:user) { create(:user, email: "foo@bar.com", password: "foobar") }

      context "valid credentials" do
        before { post :create, params: { user: valid_credentials, format: :json } }
        it { expect(response.status).to eq(200) }
        it { expect(parsed_response["user"]).to_not be_nil }
        it { expect(parsed_response["user"]["token"]).to eq(user.token) }
        it { expect(info).to be_nil }

      end

      context "invalid credentials" do
        before { post :create, params: { user: invalid_credentials, format: :json } }
        it { expect(response.status).to eq(401) }
        it { expect(parsed_response["error"]).to eq({"code"=>"CANNOT_SIGNIN_USER", "messages"=>["Cannot signin user"]}) }
      end
    end

    context "user doesn't exist" do
      before { post :create, params: { user: valid_credentials, format: :json } }
      it { expect(response.status).to eq(401) }
      it { expect(parsed_response["error"]["code"]).to eq("CANNOT_SIGNIN_USER") }
    end
  end
end
