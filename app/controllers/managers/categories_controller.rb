class Managers::CategoriesController < ApplicationController
  def index
    @categories = Category.all
    @academy = current_user.academies_as_manager.first
    skip_policy_scope
    authorize([:managers, @categories])
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    authorize([:managers, @category])
    if @category.save
      redirect_to managers_categories_path
      flash[:notice] = "Catégorie créée"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @category = Category.find(params[:id])
    @academy = current_user.academies_as_manager.first
    authorize([:managers, @category])
  end

  def update
    @category = Category.find(params[:id])
    authorize([:managers, @category])
    if @category.update(category_params)
      redirect_to managers_categories_path
      flash[:notice] = "Catégorie modifiée"
    else
      render :edit, status: :unprocessable_entity
      flash[:alert] = "Une erreur est survenue"
    end
  end

  def destroy
    @category = Category.find(params[:id])
    authorize([:managers, @category])
    @category.destroy
    redirect_to managers_categories_path
    flash[:notice] = "Catégorie supprimée"
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end
