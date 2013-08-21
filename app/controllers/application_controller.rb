class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def allow_caching
    headers['Cache-Control'] = 'public, max-age=1800'
  end
end
