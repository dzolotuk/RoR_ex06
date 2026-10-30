# The credentials come from the environment variable CLOUDINARY_URL (cloudinary://KEY:SECRET@CLOUD_NAME).
# The addresses of the images are https, like the pages of the shop.
Cloudinary.config { |config| config.secure = true }
