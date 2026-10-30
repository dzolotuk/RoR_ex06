# Uploads the images (the picture of a product, the logo of a brand) with CarrierWave.
#
# The images are stored on Cloudinary (a CDN) as soon as the credentials are given in the
# environment variable CLOUDINARY_URL. Without them (a machine without account, the tests)
# the images are stored in the folder public/uploads, so the application still works.
class ImageUploader < CarrierWave::Uploader::Base
  if Cloudinary.config.cloud_name.present? && !Rails.env.test?
    include Cloudinary::CarrierWave

    # Whatever the size of the uploaded image, Cloudinary gives a 200x200 version for the catalog.
    version(:thumb) { resize_to_fill 200, 200 }
  else
    # No resizing without Cloudinary: the thumbnail is the same file, shown small by the stylesheet.
    version :thumb
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_allowlist
    %w[jpg jpeg gif png]
  end
end
