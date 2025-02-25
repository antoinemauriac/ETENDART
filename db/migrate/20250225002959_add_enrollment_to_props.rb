class AddEnrollmentToProps < ActiveRecord::Migration[7.0]
  def change
    # Activity_enrollment doit avoir un camp_enrollment associé pour faire du nested form
    add_reference :activity_enrollments, :camp_enrollment, foreign_key: true

    # Camp_enrollment doit avoir un school_period_enrollment associé pour faire du nested form
    add_reference :camp_enrollments, :school_period_enrollment, foreign_key: true

  end
end
