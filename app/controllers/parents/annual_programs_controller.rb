class Parents::AnnualProgramsController < Parents::BaseController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @academies = policy_scope([:parents, Academy])
    @academies = @academies.new_format.joins(:annual_programs)
                                       .where(annual_programs: { ends_at: Date.today.., new: true })
                                       .distinct.group_by { |academy| academy.city }
  end

  def show
    @annual_program = AnnualProgram.includes(:academy, :activities, :program_periods).find(params[:id])
    @academy = @annual_program.academy
    authorize([:parents, @annual_program])
  end
end
