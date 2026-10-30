class User < ApplicationRecord
  # Rolify gives the roles to the users: user.add_role(:moderator), user.has_role?(:moderator)
  rolify

  # Devise modules: the email + password authentication, the registration form,
  # the "remember me" cookie and the validations of the email and of the password.
  devise :database_authenticatable, :registerable, :rememberable, :validatable

  validates :name, presence: true

  def administrator?
    has_role?(Role::ADMINISTRATOR)
  end

  def moderator?
    has_role?(Role::MODERATOR)
  end
end
