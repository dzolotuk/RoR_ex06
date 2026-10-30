RailsAdmin.config do |config|
  # The assets of the admin panel go through Sprockets (sprockets-rails and sassc-rails are in the Gemfile).
  config.asset_source = :sprockets

  # The panel uses the ApplicationController of the shop (its error handling: no Rails error page).
  config.parent_controller = '::ApplicationController'

  ### Devise: only a logged in user enters the panel (the others are sent to the login page).
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  ### CanCanCan: each page of the panel asks app/models/ability.rb (a wrong role gets "not allowed").
  config.authorize_with :cancancan

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
  end

  # The administrator gives the roles to the users in the form of the user.
  config.model 'User' do
    list do
      fields :id, :name, :email, :roles, :created_at
    end
    edit do
      fields :name, :email, :bio, :password, :password_confirmation, :roles
    end
  end

  config.model 'Role' do
    edit do
      field :name, :enum do
        enum { Role::NAMES }
      end
      field :users
    end
  end
end
