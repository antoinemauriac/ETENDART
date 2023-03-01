class Managers::CategoriesController < ApplicationController
  def index
    @categories = Category.all
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to managers_categories_path
      flash[:notice] = "Catégorie créée"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @category = Category.find(params[:id])
  end

  def update
    @category = Category.find(params[:id])
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
    @category.destroy
    redirect_to managers_categories_path
    flash[:notice] = "Catégorie supprimée"
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end
end
