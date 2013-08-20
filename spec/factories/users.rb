# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    firstname { %w{John Joe Dave Ben Linus Francis Kevin Andrew Chad Gord Steve}.sample }
    lastname { %w{Doctorow Suarez Johnson Koleman Dallas Smith Hillman George Dahlsim Kennethson Ericsen Gugenheim Weirs Marques McIntosh}.sample }
    nickname {
      ([firstname.to_s, firstname.to_s[0]].sample + ['.', '', '_'].sample + lastname.to_s).downcase
    }
    privacy false
  end
end