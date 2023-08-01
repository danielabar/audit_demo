# README

Companion project for a blog post about integrating PaperTrail for model auditing into a Rails application. Topics to be covered include:

* Using a separate `xxx_VERSIONS` table per model rather than default configuration that writes all audit records to a single `VERSIONS` table [ref](https://github.com/paper-trail-gem/paper_trail#6a-custom-version-classes)
* Using JSON columns instead of default yml columns to store object and object_changes (check what the default is?) [ref](https://github.com/paper-trail-gem/paper_trail#6b-custom-serializer)

## PaperTrail

Default PaperTrail generator:

```bash
bundle exec rails generate paper_trail:install --with-changes
# Generates the following two migrations:
# create  db/migrate/20230801103224_create_versions.rb
# create  db/migrate/20230801103225_add_object_changes_to_versions.rb
```

### Changes from default

1. Rename generated migration to `...create_product_versions.rb`
2. Add `object_changes` column in create_product_versions.rb migration file, don't need a separate migration for one column
3. Modify migration to specify `CreateProductVersions` class
4. Modify migration to specify `json` instead `text` for `object` and `object_changes` columns
5. Modify migration file to create `:product_versions` table instead of `:versions`, also modify `add_index :versions` to `:product_versions`
6. Remove MySQL specific TEXT_BYTES limit and comment about datetime precision since we're using Postgres
7. Introduce `ApplicationVersion` as an abstract class because there is no `versions` table. Note that PaperTrail Readme has `ApplicationVersion < ActiveRecord::Base` but as of 2023-08-01 and Rails 7, Rubocop Rails extension says it should be `ApplicationVersion < ActiveRecord`
8. Create custom version model class `ProductVersion`, specifying table name from migration `:product_versions`
9. Modify `Product` model to specify that it should be versioned, and specify the model class that persists the Product versions

**NOTE:** By default, PaperTrail stores `object` and `object_changes` as YAML format in text database columns (longtext for MySQL). You can specify an alternate serializer such as JSON. Even more convenient, when using Postgres and specifying either `json` or `jsonb` as column types in migration, PaperTrail will automatically use the JSON serializer, therefore no need to explicitly configure it.

### Similar as default

Modify base application controller to set whodunnit based on `current_user` (which is available because of devise). By default, this will populate `current_user.id` as whodunnit, add `user_for_paper_trail` with custom logic, for example, to populate user's email rather than id:

```ruby
class ApplicationController < ActionController::Base
  before_action :set_paper_trail_whodunnit

  # This uses devise gem's controller helper methods
  def user_for_paper_trail
    user_signed_in? ? current_user.email : "Anonymous"
  end
end
```

### Try it out

* Run migration with `bin/rails db:migrate`
* Run server with `bin/rails s`
* Navigate to `http://localhost:3000` and login as one of the seeded users in `db/seeds/users.rb`
* From the product listing page, select any product to view, then select edit, make some changes, and save
* Run Rails console with `bin/rails c`
* Find the product you edited and check its versions:
```ruby
product = Product.find_by(code: "GQKC1845")
=> #<Product:0x0000000108f984f0 id: 43, name: "Lightweight Plastic Coat", code: "GQKC1845", price: 0.531e1, inventory: 24, description: "Make a change. Eaque qui doloremque.", created_at: Mon, 31 Jul 2023 12:45:36.476309000 UTC +00:00, updated_at: Tue, 01 Aug 2023 11:29:27.578444000 UTC +00:00>
irb(main):002:0> product.versions
product.versions
=>
[#<ProductVersion:0x0000000109419768
  id: 2,
  item_type: "Product",
  item_id: 43,
  event: "update",
  whodunnit: "test1@example.com",
  object: {"name"=>"Lightweight Plastic Coat", "code"=>"GQKC1845", "price"=>"4.31", "inventory"=>23, "description"=>"Eaque qui doloremque.", "id"=>43, "created_at"=>"2023-07-31T12:45:36.476Z", "updated_at"=>"2023-07-31T12:45:36.476Z"},
  object_changes: {"price"=>["4.31", "5.31"], "inventory"=>[23, 24], "description"=>["Eaque qui doloremque.", "Make a change. Eaque qui doloremque."], "updated_at"=>["2023-07-31T12:45:36.476Z", "2023-08-01T11:29:27.578Z"]},
  created_at: Tue, 01 Aug 2023 11:29:27.578444000 UTC +00:00>]
```

Note that `object` is persisted as how the object was *before* the change.

**NOTE:** Annotate gem output from abstract base class when running migrations:
```
Unable to annotate app/models/application_version.rb: superclass must be an instance of Class (given an instance of Module)
Annotated (1): app/models/product_version.rb
```

Rails server output from editing a product - notice the insert to product_versions table:

```
Started PATCH "/products/43" for ::1 at 2023-08-01 07:29:27 -0400
Processing by ProductsController#update as TURBO_STREAM
  Parameters: {"authenticity_token"=>"[FILTERED]", "product"=>{"name"=>"Lightweight Plastic Coat", "code"=>"GQKC1845", "price"=>"5.31", "inventory"=>"24", "description"=>"Make a change. Eaque qui doloremque."}, "commit"=>"Update Product", "id"=>"43"}
  User Load (2.0ms)  SELECT "users".* FROM "users" WHERE "users"."id" = $1 ORDER BY "users"."id" ASC LIMIT $2  [["id", 5], ["LIMIT", 1]]
  ↳ app/controllers/application_controller.rb:6:in `user_for_paper_trail'
  Product Load (1.4ms)  SELECT "products".* FROM "products" WHERE "products"."id" = $1 LIMIT $2  [["id", 43], ["LIMIT", 1]]
  ↳ app/controllers/products_controller.rb:67:in `set_product'
  TRANSACTION (1.3ms)  BEGIN
  ↳ app/controllers/products_controller.rb:41:in `block in update'
  Product Update (2.2ms)  UPDATE "products" SET "price" = $1, "inventory" = $2, "description" = $3, "updated_at" = $4 WHERE "products"."id" = $5  [["price", "5.31"], ["inventory", 24], ["description", "Make a change. Eaque qui doloremque."], ["updated_at", "2023-08-01 11:29:27.578444"], ["id", 43]]
  ↳ app/controllers/products_controller.rb:41:in `block in update'
  ProductVersion Create (3.8ms)  INSERT INTO "product_versions" ("item_type", "item_id", "event", "whodunnit", "object", "object_changes", "created_at") VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING "id"  [["item_type", "Product"], ["item_id", 43], ["event", "update"], ["whodunnit", "test1@example.com"], ["object", "{\"name\":\"Lightweight Plastic Coat\",\"code\":\"GQKC1845\",\"price\":\"4.31\",\"inventory\":23,\"description\":\"Eaque qui doloremque.\",\"id\":43,\"created_at\":\"2023-07-31T12:45:36.476Z\",\"updated_at\":\"2023-07-31T12:45:36.476Z\"}"], ["object_changes", "{\"price\":[\"4.31\",\"5.31\"],\"inventory\":[23,24],\"description\":[\"Eaque qui doloremque.\",\"Make a change. Eaque qui doloremque.\"],\"updated_at\":[\"2023-07-31T12:45:36.476Z\",\"2023-08-01T11:29:27.578Z\"]}"], ["created_at", "2023-08-01 11:29:27.578444"]]
  ↳ app/controllers/products_controller.rb:41:in `block in update'
  TRANSACTION (2.9ms)  COMMIT
  ↳ app/controllers/products_controller.rb:41:in `block in update'
Redirected to http://localhost:3000/products/43
Completed 302 Found in 55ms (ActiveRecord: 18.5ms | Allocations: 26285)
```

## To be organized

Connect to database:

```bash
# development
psql -h 127.0.0.1 -p 5434 -U audit_demo
# enter password from init.sql

# test
psql -h 127.0.0.1 -p 5434 -U audit_demo -d audit_demo_test
# enter password from init.sql
```

```bash
bin/rails g scaffold Product name:string code:string price:decimal inventory:integer description:text
```

Run seeds:

```
bin/rails db:seed:replant
```

## TODO

* json vs jsonb in migration
* Fix double flash message
* Integrate simple.css
* Tabular layout for products index view (nice to have)
