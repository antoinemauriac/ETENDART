class Managers::AnnualProgramsController < ApplicationController
  def new
    @academy = Academy.find(params[:academy])
    @annual_program = AnnualProgram.new
    @annual_program.academy = @academy
    authorize [:managers, @annual_program]
    5.times { @annual_program.program_periods.build }
  end

  def create
  end

  def show
    @annual_program = AnnualProgram.find(params[:id])
    @academy = @annual_program.academy
    authorize [:managers, @annual_program]
  end

  def index
    @academy = Academy.find(params[:academy])
    @annual_programs = @academy.annual_programs
    skip_policy_scope
    authorize [:managers, @annual_programs]
  end

  def destroy
    @annual_program = AnnualProgram.find(params[:id])
    @academy = @annual_program.academy
    authorize [:managers, @annual_program]
    @annual_program.destroy
    redirect_to managers_annual_programs_path(academy_id: @academy.id)
  end

  private

  def annual_program_params
    params.require(:annual_program).permit(:year, program_periods_attributes: [:id, :start_date, :end_date, :_destroy])
  end
end
