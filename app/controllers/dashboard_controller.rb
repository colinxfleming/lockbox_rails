class DashboardController < ApplicationController
  before_filter :redirect_unauthorized_user_without_error

  def index
    if current_user.partner?
      @lockbox_partner = current_user.lockbox_partner
    else
      @lockbox_partners = LockboxPartner.all
    end
  end

  private

  def redirect_unauthorized_user_without_error
    redirect_to new_user_session_path unless signed_in?
  end
end
