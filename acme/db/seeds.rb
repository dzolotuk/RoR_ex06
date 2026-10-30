# Seeds of acme: 20 users (1 administrator, 5 moderators, 14 regular users),
# 50 brands and 2500 products (50 per brand), each with an image.
#
# The seeds can be run again: what exists is not created twice.
# SEED_PASSWORD         password of all the accounts (default "password": change it on the web)
# SEED_BRANDS           number of brands (default 50)
# SEED_PRODUCTS_PER_BRAND  number of products of each brand (default 50)
password = ENV.fetch('SEED_PASSWORD', 'password')

# The administrator of the subject.
unless User.exists?(email: 'admin@gmail.com')
  User.create!(bio: FFaker::HipsterIpsum.paragraph,
               name: 'admin',
               email: 'admin@gmail.com',
               password: password,
               password_confirmation: password)
end
User.find_by!(email: 'admin@gmail.com').add_role(Role::ADMINISTRATOR)

# The other accounts: moderator1@gmail.com ... moderator5@gmail.com, user1@gmail.com ... user14@gmail.com
{ 'moderator' => [5, Role::MODERATOR], 'user' => [14, nil] }.each do |prefix, (count, role)|
  (1..count).each do |number|
    account = User.find_or_create_by!(email: "#{prefix}#{number}@gmail.com") do |user|
      user.assign_attributes(name: "#{prefix}#{number}", bio: FFaker::HipsterIpsum.paragraph,
                             password: password, password_confirmation: password)
    end
    account.add_role(role) if role
  end
end

# The catalog, only when the shop is empty.
if Brand.none?
  brands_count = Integer(ENV.fetch('SEED_BRANDS', 50))
  products_per_brand = Integer(ENV.fetch('SEED_PRODUCTS_PER_BRAND', 50))
  price = [9.99, 14.5, 19.99, 29.9, 49.0, 79.99, 99.0, 149.99, 249.0]
  placeholder = Rails.root.join('db/seeds/placeholder.png')

  # The subject uses open(url): since Ruby 3.0 it is URI.open(url). The image is saved in a temporary
  # file with a real name, because CarrierWave needs the name. If the download fails (no internet),
  # the picture db/seeds/placeholder.png is used instead.
  open_image = lambda do |url|
    downloaded = URI.parse(url).open(read_timeout: 15, open_timeout: 15)
    file = Tempfile.new(['seed', '.png'], binmode: true)
    file.write(downloaded.read)
    file.rewind
    file
  rescue StandardError
    File.open(placeholder)
  end

  brands_count.times do |tm|
    mk = Brand.create!(name: FFaker::Product.brand,
                       avatar: open_image.call(FFaker::Avatar.image))

    products_per_brand.times do |tw|
      Product.create!(name: FFaker::Product.product,
                      pict: open_image.call(FFaker::Avatar.image),
                      description: FFaker::HipsterIpsum.paragraph,
                      brand_id: mk.id, price: price.sample)
    end
    puts "Brand #{tm + 1}/#{brands_count} created with #{products_per_brand} products"
  end
end
