FactoryBot.define do
  factory :merchant do
    code { rand(9999) }
    name { Faker::Company.name }
  end
end
