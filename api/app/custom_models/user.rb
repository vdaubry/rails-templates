class User < ActiveRecord::Base
  has_secure_password
  
  validates :email, :token, presence: true, uniqueness: true
end