20.times do
  Product.create!(
    name: Faker::Commerce.product_name,
    code: "#{Faker::Alphanumeric.alpha(number: 4).upcase}#{Faker::Number.number(digits: 4)}",
    price: Faker::Commerce.price(range: 0..100.0),
    inventory: rand(0..50),
    description: Faker::Lorem.sentence(word_count: 3, random_words_to_add: 4)
  )
end
