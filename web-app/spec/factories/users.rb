FactoryBot.define do
  factory :user do
    sequence(:email)  {|n| "string#{n}@example.com" }
    password          { "string" }
    sequence(:token)  {|n| "string#{n}" }
    sequence(:refresh_token)  {|n| "string#{n}" }
  end
end
