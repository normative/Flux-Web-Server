# Read about factories at https://github.com/thoughtbot/factory_girl
include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :image do
    raw_latitude { 40 + rand(1000000) / 1000000.0 }
    raw_longitude  { -80 + rand(1000000) / 1000000.0 }
    raw_altitude 1.5
    best_latitude { raw_latitude }
    best_longitude { raw_longitude }
    best_altitude { raw_altitude }
    raw_yaw 1.5
    raw_pitch { rand(360) }
    raw_roll { rand(360) }
    best_yaw { raw_yaw }
    best_pitch { raw_pitch }
    best_roll { raw_roll }
    description "Some desc..."
    category { Category.all.sample }
    camera { Camera.all.sample }
    user { camera.user }
    heading { rand(360) }
    image { fixture_file_upload( "spec/fixtures/logo#{rand 1..10}.png", 'image/png') }
  end
end
