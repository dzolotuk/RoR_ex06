# What each user can do (CanCanCan). The administration panel (RailsAdmin) asks it for each page.
class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.nil? || user.roles.empty?

    if user.administrator?
      administrator_rights
    elsif user.moderator?
      moderator_rights
    end
  end

  private

  # An administrator can edit EVERYTHING (including the roles of the users).
  def administrator_rights
    can :access, :rails_admin
    can :manage, :all
  end

  # A moderator can ONLY create, modify and delete the brands and the products.
  def moderator_rights
    can :access, :rails_admin
    can :read, :dashboard
    can :manage, [Brand, Product]
  end
end
