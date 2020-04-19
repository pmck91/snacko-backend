class ApplicationController < ActionController::API
  include Knock::Authenticable

  def authorize_as_admin
    unauthorized_entity(current_user) unless !current_user.nil? && current_user.is_admin?
  end
end
