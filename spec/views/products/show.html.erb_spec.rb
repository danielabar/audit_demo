require "rails_helper"

RSpec.describe "products/show" do
  before do
    assign(:product, Product.create!(
                       name: "Name",
                       code: "Code",
                       price: "9.99",
                       inventory: 2,
                       description: "MyText"
                     ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Code/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/MyText/)
  end
end
