module Api
  module V0
  class UserSerializer < ActiveModel::Serializer
    attributes :id,
               :email,
               :first_name,
               :last_name,
               :token
  end
end
end