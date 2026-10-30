class Product < ApplicationRecord
  mount_uploader :pict, ImageUploader

  belongs_to :brand
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :nullify

  validates :name, :description, :pict, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
end
