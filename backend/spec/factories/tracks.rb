FactoryBot.define do
  factory :track do
    sequence(:flight_id) { |n| "TEST#{n.to_s.rjust(5, '0')}" }
    sequence(:timestamp) { |n| Time.utc(2024, 1, 1, 0, n * 1, 0) }
    sequence(:lat) { |n| 35.0 + n * 0.05 }
    sequence(:lon) { |n| 139.0 + n * 0.03 }
    alt { 35000 }
    aircraft_type { "A320" }
  end
end
