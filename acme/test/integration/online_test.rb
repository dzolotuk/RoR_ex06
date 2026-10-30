require 'test_helper'

class OnlineTest < ActionDispatch::IntegrationTest
  test 'the login of the author is visible on every page' do
    [root_path, brands_path, cart_path, new_user_session_path].each do |path|
      get path
      assert_match(%r{<strong class="author">dzolotuk</strong>}, response.body, path)
    end
  end

  test 'the login of the author comes from the environment of the host' do
    Rails.configuration.x.author_login = 'jdoe'
    get root_path
    assert_match(%r{<strong class="author">jdoe</strong>}, response.body)
  ensure
    Rails.configuration.x.author_login = 'dzolotuk'
  end

  test 'the host knows how to start the application' do
    procfile = File.read(Rails.root.join('Procfile'))
    assert_match(/^web: bundle exec puma/, procfile)
    assert_match(/^release: bundle exec rails db:migrate/, procfile)
    assert File.executable?(Rails.root.join('bin/render-build.sh'))
  end
end
