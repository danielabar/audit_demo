require "rails_helper"

RSpec.describe "products/new" do
  before do
    assign(:product, Product.new(
                       name: "MyString",
                       code: "MyString",
                       price: "9.99",
                       inventory: 1,
                       description: "MyText"
                     ))
  end

  it "renders new product form" do
    render

    assert_select "form[action=?][method=?]", products_path, "post" do
      assert_select "input[name=?]", "product[name]"

      assert_select "input[name=?]", "product[code]"

      assert_select "input[name=?]", "product[price]"

      assert_select "input[name=?]", "product[inventory]"

      assert_select "textarea[name=?]", "product[description]"
    end
  end
end
