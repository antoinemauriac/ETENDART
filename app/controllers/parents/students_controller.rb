class Parents::StudentsController < ApplicationController
  before_action :set_parent

  def index
    @students = policy_scope([:parents, Student])
    authorize [:parents, :student], :index?
  end

  def new
    @student = Student.new
    authorize [:parents, :student], :new?
  end

  def create
    @student = Student.new(student_params)
    authorize [:parents, :students], :create?
    @student.parent = @parent
    if @student.save
      redirect_to parents_student_path(@student), notice: 'L\'élève a bien été créé.'
    else
      render :new, alert: 'Une erreur est survenue.'
    end
  end

  def show
    @student = Student.find(params[:id])
    authorize [:parents, :students], :show?
  end

  def edit
    @student = Student.find(params[:id])
    authorize [:parents, :students], :edit?
  end

  def update
    @student = Student.find(params[:id])
    authorize [:parents, :students], :update?
    if @student.update(student_params)
      redirect_to parents_student_path(@student), notice: 'L\'élève a bien été mis à jour.'
    else
      render :edit, alert: 'Une erreur est survenue lors de la modification de l\'élève.'
    end
  end

  private

  def set_parent
    @parent = current_user
    @parent_profile = @parent.parent_profile
  end

end
