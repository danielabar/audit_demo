# == Schema Information
#
# Table name: products
#
#  id          :bigint           not null, primary key
#  code        :string
#  description :text
#  inventory   :integer
#  name        :string
#  price       :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :product do
    name { "MyString" }
    code { "MyString" }
    price { "9.99" }
    inventory { 1 }
    description { "MyText" }
  end
end
