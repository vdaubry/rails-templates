require 'rails_helper'

describe Api::V0::BaseController, type: :controller do
  describe "current_user" do
    context "valid user" do
      let!(:valid_user) { create(:user, token: "validfoo") }
      before { @request.env['Authorization'] = 'Bearer validfoo' }
      it { expect(controller.current_user).to eq(valid_user) }
    end

    context "refresh token" do
      let!(:valid_user) { create(:user, refresh_token: "validfoo") }
      before { @request.env['Authorization'] = 'Bearer validfoo' }
      it { expect(controller.current_user).to eq(valid_user) }
    end

    context "unknown token" do
      let!(:valid_user) { create(:user, token: "validfoo") }
      before { @request.env['Authorization'] = 'foo' }
      it { expect(controller.current_user).to be nil }
    end

    context "missing token" do
      it { expect(controller.current_user).to be nil }
    end
  end

  describe 'offset' do
    context "has offset" do
      before { controller.params[:offset]="1" }
      it { expect(controller.offset).to eq(1) }
    end

    context "no offset" do
      it { expect(controller.offset).to eq(0) }
    end

    context "has offset as integer" do
      before { controller.params[:offset]=1 }
      it { expect(controller.offset).to eq(1) }
    end
  end

  describe 'count' do
    context "has count" do
      before { controller.params[:count]="20" }
      it { expect(controller.count).to eq(20) }
    end

    context "no count" do
      it { expect(controller.count).to eq(25) }
    end

    context "count too large" do
      before { controller.params[:count]=200 }
      it { expect(controller.count).to eq(25) }
    end

    context "has count as integer" do
      before { controller.params[:count]=1 }
      it { expect(controller.count).to eq(1) }
    end
  end

  describe "set_language" do
    let(:user) { create(:user) }

    context "no accept language header" do
      before { get :check, params: { token: user.token }}
      it { expect(user.reload.language).to eq('fr') }
    end

    context "has accept language header" do
      before { @request.env['Accept-Language'] = 'en' }
      before { get :check, params: { token: "Bearer #{user.token}" } }
      it { expect(user.reload.language).to eq('en') }
    end
  end
end
