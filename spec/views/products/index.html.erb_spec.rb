require "rails_helper"

RSpec.describe "products/index" do
  before do
    assign(:products, [
             Product.create!(
               name: "Name",
               code: "Code",
               price: "9.99",
               inventory: 2,
               description: "MyText"
             ),
             Product.create!(
               name: "Name",
               code: "Code",
               price: "9.99",
               inventory: 2,
               description: "MyText"
             )
           ])
  end

  it "renders a list of products" do
    render
    cell_selector = Rails::VERSION::STRING >= "7" ? "div>p" : "tr>td"
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Code".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("9.99".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
    assert_select cell_selector, text: Regexp.new("MyText".to_s), count: 2
  end
end
