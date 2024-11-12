class AddColumFreeJudoToSchoolPeriods < ActiveRecord::Migration[7.0]
  def change
    add_column :school_periods, :free_judo, :boolean, default: false
  end
end
