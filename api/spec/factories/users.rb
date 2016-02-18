FactoryGirl.define do
  factory :user do
    sequence(:email)  {|n| "string#{n}@example.com" }
    password          "string"
    token             {|n| "string#{n}" }
  end
end