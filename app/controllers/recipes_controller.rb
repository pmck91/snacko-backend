class RecipesController < ApplicationController

  def index
    @recipes = Recipe.all
    render :json => @recipes.to_json(:include => [:steps, :ingredients, :tags])
  end

  def show
    @recipe = Recipe.find(params[:id])
    render :json => @recipe.to_json(:include => [:steps, :ingredients, :tags])
  end

end
