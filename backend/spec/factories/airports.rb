FactoryBot.define do
  factory :airport do
    country_code { "JP" }
    sequence(:icao_code) { |n| "TEST#{n}" }
    sequence(:label) { |n| "TEST AIRPORT#{n}" }
    sequence(:lat) { |n| 35.0 + n * 0.05 }
    sequence(:lon) { |n| 139.0 + n * 0.03 }
    uri { "http://example.com/test" }
    status { 1 }
  end
end
