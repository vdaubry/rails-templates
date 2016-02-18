require 'rails_helper'

describe User do
  
  let(:user) { FactoryGirl.create(:user) }
  
  describe "validation" do
    it { FactoryGirl.build(:user).save.should == true }
    it { should validate_presence_of :email }
    it { should validate_presence_of :password }
    it { should validate_presence_of :token }

    it "enforces unique email" do
      FactoryGirl.build(:user, email: "foo@bar.com").save.should == true
      FactoryGirl.build(:user, email: "foo@bar.com").save.should == false
    end
    
    it "enforces unique token" do
      FactoryGirl.build(:user, token: "foobar").save.should == true
      FactoryGirl.build(:user, token: "foobar").save.should == false
    end
  end
  
  describe "create" do
    it "encrypts password" do
      user = FactoryGirl.create(:user, password: "foo")
      saved_user = User.first
      saved_user.password_digest.should_not == "foo"
      saved_user.password.should == nil
    end

    it "fails if password confirmation doesn't match" do
      FactoryGirl.build(:user, password: "foo", password_confirmation: "foo1").save.should == false
    end
  end
  
  describe "update" do
    it "encrypts password when password changes" do
      old_encrypted_password = user.password_digest
      user.password = "new pass"
      user.save
      user.reload.password_digest.should_not == old_encrypted_password
    end
    
    it "doesn't encrypt password when password doesn't change" do
      old_encrypted_password = user.password_digest
      user.email = "new@email.com"
      user.save
      user.reload.password_digest.should == old_encrypted_password
    end
  end
  
end