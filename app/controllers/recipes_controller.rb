class RecipesController < ApplicationController

  def index
    @recipes = Recipe.all
    render :json => @recipes.to_json(:include => [:steps, :ingredients, :tags])
  end

  def show
    @recipe = Recipe.find_by slug: params[:slug]
    render :json => @recipe.to_json(:include => [:steps, :ingredients, :tags])
  end

  def by_tag
    @tag = Tag.find_by_value(params[:tag])

  end

  def create
    params = recipe_params
    @recipe = {}
    ActiveRecord::Base.transaction do
      @recipe = Recipe.create!(title: params[:title], description: params[:description], slug: params[:slug])
      # save the steps
      params[:steps].each do |step|
        Step.create!(title: step[:title], body: step[:body], position: step[:position], recipe: @recipe)
      end
      # save the ingredients
      params[:ingredients].each do |step|
        Ingredient.create!(name: step[:name], quantity: step[:quantity], measurement: step[:measurement], recipe: @recipe)
      end
      # save or load the tags
      params[:tags].each do |tag|
        t = Tag.find_by value: tag[:value]
        t ? @recipe.tags << t : @recipe.tags << Tag.create!(value: tag[:value])
      end
    end

    redirect_to action: "show", slug: @recipe.slug
  rescue ActiveRecord::RecordInvalid => e
    render :json => {error: e}
  end

  def delete
    @recipe = Recipe.find(params[:id])
    if @recipe.destroy
      render :json => {message: "recipe deleted"}
    end
  end

  private

  def recipe_params
    params.require(:recipe).permit(:title, :description, :slug, steps: [:title, :body, :position], ingredients: [:name, :quantity, :measurement], tags: [:value])
  end


end
