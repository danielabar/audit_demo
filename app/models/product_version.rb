# == Schema Information
#
# Table name: product_versions
#
#  id             :bigint           not null, primary key
#  event          :string           not null
#  item_type      :string           not null
#  object         :json
#  object_changes :json
#  whodunnit      :string
#  created_at     :datetime
#  item_id        :bigint           not null
#
# Indexes
#
#  index_product_versions_on_item_type_and_item_id  (item_type,item_id)
#
class ProductVersion < PaperTrail::Version
  self.table_name = :product_versions
end
