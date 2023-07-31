require "rails_helper"

RSpec.describe "products/edit" do
  let(:product) do
    Product.create!(
      name: "MyString",
      code: "MyString",
      price: "9.99",
      inventory: 1,
      description: "MyText"
    )
  end

  before do
    assign(:product, product)
  end

  it "renders the edit product form" do
    render

    assert_select "form[action=?][method=?]", product_path(product), "post" do
      assert_select "input[name=?]", "product[name]"

      assert_select "input[name=?]", "product[code]"

      assert_select "input[name=?]", "product[price]"

      assert_select "input[name=?]", "product[inventory]"

      assert_select "textarea[name=?]", "product[description]"
    end
  end
end
