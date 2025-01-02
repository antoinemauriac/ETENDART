class Parents::ProfilesController < ApplicationController
  def new
    @parent_profile = ParentProfile.new
  end
end
