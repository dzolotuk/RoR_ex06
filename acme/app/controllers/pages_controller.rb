class PagesController < ApplicationController
  # An address that does not exist: no Rails error page, back to the root page.
  def missing
    redirect_to root_path, alert: 'This page does not exist', status: :see_other
  end
end
