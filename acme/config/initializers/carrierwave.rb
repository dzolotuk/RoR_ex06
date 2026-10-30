# The images of the tests go to tmp/ and not to public/.
CarrierWave.configure do |config|
  config.root = Rails.root.join('tmp/test_uploads') if Rails.env.test?
end
