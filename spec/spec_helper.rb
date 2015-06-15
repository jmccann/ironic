require 'chefspec'
require 'chefspec/berkshelf'
require 'chef-vault/test_fixtures'

RSpec.configure do |config|
  config.log_level = :error
end

# def populate_databags(server)
#   Dir['../test/integration/data_bags/*'].each do |db|
#     items = {}
#     Dir["../test/integration/data_bags/#{db}/*"].each do |item_file|
#       item = File.basename(item_file).gsub('.json', '')
#       items[item] = JSON.parse File.read(item_file)
#     end
#     server.create_data_bag(db, items)
#   end
#
#   # server.create_data_bag('my_data_bag', {
#   #   'item_1' => {
#   #     'password' => 'abc123'
#   #   },
#   #   'item_2' => {
#   #     'password' => 'def456'
#   #   }
#   # })
# end

at_exit { ChefSpec::Coverage.report! }
