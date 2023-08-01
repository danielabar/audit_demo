class ApplicationController < ActionController::Base
  before_action :set_paper_trail_whodunnit

  # This uses devise gem's controller helper methods
  def user_for_paper_trail
    user_signed_in? ? current_user.email : "Anonymous"
  end
end
