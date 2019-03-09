require 'rails_helper'

RSpec.describe RecoverPasswordsController, type: :controller do

  let(:user) { create(:user) }
  before { $redis.set("1job1passion:users:foobar:reset_password_token", user.id) }

  describe "GET show" do
    context "valid reset token" do
      before { get :new, params: { recovery_token: "foobar" } }
      it { should render_template :new }
      it { expect(assigns(:recovery_token)).to eq("foobar") }
    end

    context "invalid reset token" do
      before { get :new, params: {recovery_token: "wrong_token"} }
      it { expect(response.body).to eq("Link invalid, please check your reset password email link") }
    end
  end

  describe "POST create" do
    context "valid password" do
      before { post :create, params: {password: "Foobar123", password_confirmation: "Foobar123", recovery_token: "foobar" }}
      it { expect(response.body).to eq("Votre mot de passe a bien été mis à jour") }
    end

    context "password doesn't match" do
      before { post :create, params: {password: "Foobar123", password_confirmation: "other", recovery_token: "foobar"} }
      it { should render_template :new }
    end

    context "invalid reset token" do
      before { post :create, params: {password: "Foobar123", password_confirmation: "Foobar123"} }
      it { expect(response.body).to eq("Link invalid, please check your reset password email link") }
    end
  end
end
