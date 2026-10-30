class Brand < ApplicationRecord
  mount_uploader :avatar, ImageUploader

  has_many :products, dependent: :destroy

  validates :name, :avatar, presence: true
end
