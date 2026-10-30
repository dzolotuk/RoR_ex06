require 'test_helper'

class DatabaseTest < ActionDispatch::IntegrationTest
  test 'the application uses PostgreSQL' do
    assert_equal 'PostgreSQL', ActiveRecord::Base.connection.adapter_name
  end

  test 'the database is encoded in UTF-8 and the connection works' do
    assert_equal 'UTF8', ActiveRecord::Base.connection.encoding
    assert_equal 1, ActiveRecord::Base.connection.select_value('SELECT 1')
  end

  test 'the databases are named after the application' do
    assert_equal 'acme_test', ActiveRecord::Base.connection.current_database
  end
end
