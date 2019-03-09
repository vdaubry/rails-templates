require 'rails_helper'

RSpec.describe Api::V0::RegisterController, type: :controller do

  let(:valid_attributes) { {
    email: "foo@bar.com",
    password: "foobar",
    first_name: "foo",
    last_name: "bar",
    cloudinary_avatar_id: "foo_foo"
  } }

  let(:invalid_attributes) { {email: "foobar", password: "foobar"} }

  describe "POST create" do
    context "valid attributes" do
      before { post :create, params: { user: valid_attributes, format: :json } }
      it { expect(response.status).to eq(201) }
      it {
        expect(parsed_response["user"]).to_not be_nil
      }
      it { expect(parsed_response["user"]["email"]).to eq("foo@bar.com") }
      it { expect(parsed_response["user"]["first_name"]).to eq("foo") }
      it { expect(parsed_response["user"]["last_name"]).to eq("bar") }
      it { expect(parsed_response["user"]["token"]).to eq(User.last.token) }
      it { expect(parsed_response["user"]["refresh_token"]).to eq(User.last.refresh_token) }
      it { expect(parsed_response["user"]["avatar_url"]).to eq("https://res.cloudinary.com/hda06s1ql/image/upload/c_scale,w_300/foo_foo") }
    end

    context "invalid attributes" do
      before { post :create, params: { user: invalid_attributes, format: :json } }
      it { expect(response.status).to eq(400) }
      it { expect(parsed_response["user"]).to be_nil }
      it { expect(parsed_response["error"]["code"]).to eq("CANNOT_CREATE_USER")}
    end

    context "email already taken" do
      before { I18n.locale = "fr" }
      let!(:existing_user) { create(:user, email: "foo@bar.com") }
      before { post :create, params: { user: valid_attributes, format: :json } }
      it { expect(response.status).to eq(400) }
      it { expect(parsed_response["user"]).to be_nil }
      it { expect(parsed_response["error"]["messages"]).to eq(["Email n'est pas disponible"])}
    end
  end
end
