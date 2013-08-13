# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:number) { |n| n.to_s }

  factory :category do
    cat_description { "Cat desc... " + generate(:number) }
    cat_text { "Cat" + generate(:number) }
  end
end
