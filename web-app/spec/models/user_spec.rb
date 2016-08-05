require 'rails_helper'

describe User do
  
  let(:user) { FactoryGirl.create(:user) }
  
  describe "validation" do
    it { expect(FactoryGirl.build(:user).save).to be true }
    it { should validate_presence_of :email }
    it { should validate_presence_of :password }

    it "enforces unique email" do
      expect(FactoryGirl.build(:user, email: "foo@bar.com").save).to be true
      expect(FactoryGirl.build(:user, email: "foo@bar.com").save).to be false
    end
  end
  
  describe "create" do
    it "encrypts password" do
      user = FactoryGirl.create(:user, password: "foo")
      saved_user = User.first
      expect(saved_user.password_digest).to_not eq("foo")
      expect(saved_user.password).to be nil
    end

    it "fails if password confirmation doesn't match" do
      expect(FactoryGirl.build(:user, password: "foo", password_confirmation: "foo1").save).to be false
    end
  end
  
  describe "update" do
    it "encrypts password when password changes" do
      old_encrypted_password = user.password_digest
      user.password = "new pass"
      user.save
      expect(user.reload.password_digest).to_not eq(old_encrypted_password)
    end
    
    it "doesn't encrypt password when password doesn't change" do
      old_encrypted_password = user.password_digest
      user.email = "new@email.com"
      user.save
      expect(user.reload.password_digest).to eq(old_encrypted_password)
    end
  end
  
end