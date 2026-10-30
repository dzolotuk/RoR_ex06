# acme - Exercise 06 - Show me what you got

The application online, with the final seeds.

* **Seeds**: 20 users (1 administrator, 5 moderators, 14 regular users), 50 brands, 2500 products with images.
  `SEED_PASSWORD` chooses the password of all the accounts (use it online: the default `password` is public knowledge).
* **Your login visible on the website**: the footer of every page says `made by <login>`. The login comes from the
  environment variable `AUTHOR_LOGIN` (default `dzolotuk`, so locally nothing to do; online you can set it explicitly).
* All the features of the subject work online: image upload (Cloudinary), authentication (Devise), cart, roles, panel.

## Run the application

```bash
bundle install
bin/rails db:create db:migrate db:seed     # the seeds can be run again and again
bin/rails server                           # then open http://localhost:3000
```

To start again from zero: `bin/rails db:drop db:create db:migrate db:seed`.

The full catalog (50 brands x 50 products, every image uploaded) takes a long time. For a quick try: `SEED_BRANDS=3 SEED_PRODUCTS_PER_BRAND=5 bin/rails db:seed`.

## Putting it online (example with Render, free plan)

The same steps work for any host that runs a Rails app with PostgreSQL (Heroku and others read the `Procfile`).

1. Push the project (the folder `ex06/acme`) to GitHub.
2. Cloudinary: keep your `CLOUDINARY_URL` (see above). The host's disk is erased at each deploy, so Cloudinary is where the images live.
3. Render: **New + -> PostgreSQL** (free), copy its *Internal Database URL* (for the web service) and its *External Database URL* (for the seeds).
4. Render: **New + -> Web Service**, choose the repository, *Root Directory* `ex06/acme`, *Runtime* Ruby, then
   *Build Command* `./bin/render-build.sh`, *Start Command* `bundle exec puma -C config/puma.rb`.
5. Environment variables of the web service:

   | variable | value |
   |---|---|
   | `RAILS_ENV` | `production` |
   | `DATABASE_URL` | the Internal Database URL |
   | `SECRET_KEY_BASE` | the output of `bin/rails secret` |
   | `CLOUDINARY_URL` | `cloudinary://KEY:SECRET@CLOUD_NAME` |
   | `AUTHOR_LOGIN` | `dzolotuk` |
   | `FORCE_SSL` | `true` |
   | `RAILS_LOG_TO_STDOUT` | `true` |
   | `RUBY_VERSION` | `3.0.2` |

6. Deploy. Then fill the online database **from your own machine** (the 2550 uploads are too long for a build):

   ```bash
   export CLOUDINARY_URL='cloudinary://KEY:SECRET@CLOUD_NAME'
   RAILS_ENV=production SECRET_KEY_BASE=$(bin/rails secret) FORCE_SSL=false \
   DATABASE_URL='<External Database URL>' SEED_PASSWORD='choose-a-password' \
   bin/rails db:migrate db:seed
   ```

   (A smaller catalog for a first try: add `SEED_BRANDS=5 SEED_PRODUCTS_PER_BRAND=10`.)
7. Open the address of the web service: the catalog, your login in the footer, `/admin` with the admin account.

## Accounts created by the seeds

| email | password | role |
|---|---|---|
| admin@gmail.com | password (or `SEED_PASSWORD`) | administrator |
| moderator1@gmail.com ... moderator5@gmail.com | same | moderator |
| user1@gmail.com ... user14@gmail.com | same | none (regular user) |

Plus 50 brands x 50 products.

## Tests

```bash
bin/rails test
```

`bin/rails test` runs ALL the tests of the project. At every exercise all of them pass: the
tests of the earlier exercises are kept (they check that nothing was broken). The test files
**new or changed in this exercise** are listed below, run them alone with `bin/rails test <file> ...`.

Test files of this exercise:

* `test/integration/online_test.rb`
* `test/integration/seeds_test.rb`

```bash
bin/rails test test/integration/online_test.rb test/integration/seeds_test.rb
```

## Manual checks

1. Online: the footer shows your login; Register a new account; add products to the cart and checkout.
2. Login as `admin@gmail.com`: the panel, give a role to a user. Login as `moderator1@gmail.com`: only Brand and Product.
3. Create a product with an image in the panel: the image appears in the catalog (stored on Cloudinary).

## Quality check (asked by the subject)

```bash
bundle exec rubycritic        # expected: Score >= 89 (about 97 here); .rubycritic.yml makes it judge app/
```
