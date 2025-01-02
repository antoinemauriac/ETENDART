class Parents::ProfilesController < ApplicationController
  def new
    @parent = current_user
    authorize [:parents, :profiles], :new?
    @parent_profile = ParentProfile.new
  end
end
