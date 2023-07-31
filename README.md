# README

Companion project for a blog post about integrating PaperTrail for model auditing into a Rails application. Topics to be covered include:

* Using a separate `xxx_VERSIONS` table per model rather than default configuration that writes all audit records to a single `VERSIONS` table.
* Using JSON columns instead of default yml columns to store object and object_changes (check what the default is?)

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

* Fix double flash message
* Integrate simple.css
* Tabular layout for products index view (nice to have)
