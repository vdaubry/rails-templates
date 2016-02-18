require 'rails_helper'

describe SessionsController do
  render_views
  
  let(:user) { FactoryGirl.create(:user, email: "foo@bar.com", password: "foo") }
  
  describe "POST create" do
    context "valid credentials" do
      it "sets user session" do
        post :create, email: user.email, password: "foo"
        session[:user_id].should == User.last.id
      end
      
      it "redirects to home" do
        post :create, email: user.email, password: "foo"
        response.should redirect_to root_path
      end
    end
    
    context "invalid credentials" do
      it "doesn't set user session" do
        post :create, email: user.email, password: "invalid"
        session[:user_id].should == nil
      end
      
      it "redirects to sign in page" do
        post :create, email: user.email, password: "invalid"
        response.should redirect_to new_session_path
      end
    end
  end 
end