namespace :carts do
  desc 'Remove the carts nobody used for 30 days (and their items)'
  task purge: :environment do
    puts "#{Cart.purge_abandoned} abandoned carts removed"
  end
end
