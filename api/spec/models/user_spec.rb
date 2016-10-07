require 'rails_helper'

describe User do
  
  describe "validation" do
    it { FactoryGirl.build(:user).save.should == true }
    it { should validate_presence_of :email }
    it { should validate_presence_of :password }
    it { should validate_presence_of :token }

    it "enforces unique email" do
      expect(FactoryGirl.build(:user, email: "foo@bar.com").save).to be true
      expect(FactoryGirl.build(:user, email: "foo@bar.com").save).to be false
    end
    
    it "enforces unique token" do
      expect(FactoryGirl.build(:user, token: "foobar").save).to be true
      expect(FactoryGirl.build(:user, token: "foobar").save).to be false
    end
  end
  
  describe "create" do
    describe "encrypts password" do
      let!(:user) { FactoryGirl.create(:user, password: "foo") }
      let(:saved_user) { User.first }
      it { expect(saved_user.password_digest).to_not eq("foo") }
      it { expect(saved_user.password).to be nil }
    end
    
    describe "password confirmation doesn't match" do
      it { expect(FactoryGirl.build(:user, password: "foo", password_confirmation: "foo1").save).to be false }
    end
  end
  
  describe "update" do
    let!(:user) { FactoryGirl.create(:user) }
    
    describe "encrypts password when password changes" do  
      let!(:old_encrypted_password) { user.password_digest }
      before { user.update(password: "new_pass")}
      it { expect(user.reload.password_digest).to_not eq(old_encrypted_password) }
    end
    
    describe "doesn't encrypt password when password doesn't change" do
      let!(:old_encrypted_password) { user.password_digest }
      before { user.update(email: "new@email.com")}
      it { expect(user.reload.password_digest).to eq(old_encrypted_password) }
    end
  end
  
end