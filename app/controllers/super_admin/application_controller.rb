# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module SuperAdmin
  class ApplicationController < Administrate::ApplicationController
    before_action :authenticate_super_admin

    def authenticate_super_admin
      # TODO Add authentication logic here.
      # For example, you might want to check if the user is a super_admin
      # unless current_user&.super_admin?
      #   redirect_to root_path, alert: "Vous n'avez pas accès à cette page."
      # end
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end
  end
end
