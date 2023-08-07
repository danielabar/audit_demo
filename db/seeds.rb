if Rails.env.development?
  load Rails.root.join("db/seeds/users.rb")
  load Rails.root.join("db/seeds/products.rb")
  Rails.logger.info("Seeding completed!")
else
  Rails.logger.info("Seeding skipped. Not in development environment.")
end
