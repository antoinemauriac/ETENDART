class Managers::AnnualProgramsController < ApplicationController

  def index
    @academy = Academy.find(params[:academy])
    @annual_programs = @academy.annual_programs
    skip_policy_scope
    authorize [:managers, @annual_programs]
  end

  def new
    @academy = Academy.find(params[:academy])
    @annual_program = AnnualProgram.new
    @annual_program.academy = @academy
    authorize [:managers, @annual_program]

    program_periods_defaults = [
      { start_date: Date.parse('25/09/2023'), end_date: Date.parse('20/10/2023') },
      { start_date: Date.parse('30/10/2023'), end_date: Date.parse('15/12/2023') },
      { start_date: Date.parse('08/01/2024'), end_date: Date.parse('16/02/2024') },
      { start_date: Date.parse('04/03/2024'), end_date: Date.parse('12/04/2024') },
      { start_date: Date.parse('22/04/2024'), end_date: Date.parse('14/06/2024') }
    ]

    @default_program_periods = program_periods_defaults.map do |period_params|
      ProgramPeriod.new(period_params)
    end
  end

  def create
    academy = Academy.find(params[:academy])
    annual_program = academy.annual_programs.build(annual_program_params)
    annual_program.update(end_year: annual_program.start_year + 1)
    authorize [:managers, annual_program]

    if annual_program.save
      redirect_to managers_annual_program_path(annual_program), notice: 'Le programme annuel a été créé avec succès.'
    else
      render :new
    end
  end

  def show
    @annual_program = AnnualProgram.find(params[:id])
    @academy = @annual_program.academy
    authorize [:managers, @annual_program]
    @activities = @annual_program.sorted_activities
  end

  def destroy
    annual_program = AnnualProgram.find(params[:id])
    academy = annual_program.academy
    authorize [:managers, annual_program]
    annual_program.destroy
    redirect_to managers_annual_programs_path(academy: academy)
    flash[:notice] = "Activité supprimée"
  end

  private

  def annual_program_params
    params.require(:annual_program).permit(:start_year, program_periods_attributes: [:id, :start_date, :end_date, :_destroy])
  end
end
