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
class Product < ApplicationRecord
  validates :code, :description, :inventory, :name, :price, presence: true

  # https://github.com/paper-trail-gem/paper_trail#6a-custom-version-classes
  has_paper_trail versions: {
    class_name: "ProductVersion"
  }
end
