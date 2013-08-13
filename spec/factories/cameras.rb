# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :camera do
    user { User.all.sample }
    model "SomeModel"
    deviceid "12345"
    description "desc..."
    nickname "SomeCamera"
  end
end
