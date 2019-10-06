class User < ActiveRecord::Base
  has_secure_password
  
  validates :email, presence: true, uniqueness: true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, if: Proc.new{|u| u.email }
end