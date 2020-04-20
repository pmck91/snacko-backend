class RecipesController < ApplicationController

  before_action :authorize_as_admin, only: [:create, :update, :destroy]

  def index
    @recipes = Recipe.all
    paged_recipes = @recipes.paginate(page: params[:page], per_page: params[:per_page])
    render :json => render_recipe(paged_recipes)
  end

  def show
    @recipe = Recipe.find_by slug: params[:slug]
    render :json => render_recipe(@recipes)
  end

  def search
    @recipes = Recipe.search(search_params[:query])
    paged_recipes = @recipes.paginate(page: params[:page], per_page: params[:per_page])
    render json: {query: search_params[:query], recipes: JSON[render_search_recipe(paged_recipes)]}
  end

  def by_tag
    @tag = Tag.find_by_value(params[:tag])
    @recipes = Recipe.joins(:tags).where("tags.id", @tag.id)
    paged_recipes = @recipes.paginate(page: params[:page], per_page: params[:per_page])
    paginate :json => render_recipe(paged_recipes)
  end

  def create
    post_params = recipe_params
    @recipe = {}
    ActiveRecord::Base.transaction do
      @recipe = Recipe.create!(title: post_params[:title], description: post_params[:description], slug: post_params[:slug])

      # save the steps
      post_params[:steps].each do |step|
        Step.create!(title: step[:title], body: step[:body], position: step[:position], recipe: @recipe)
      end
      # save the ingredients
      post_params[:ingredients].each do |step|
        Ingredient.create!(name: step[:name], quantity: step[:quantity], measurement: step[:measurement], recipe: @recipe)
      end
      # save or load the tags
      post_params[:tags].each do |tag|
        t = Tag.find_by value: tag[:value]
        t ? @recipe.tags << t : @recipe.tags << Tag.create!(value: tag[:value])
      end
    end

    redirect_to action: "show", slug: @recipe.slug
  rescue ActiveRecord::RecordInvalid => e
    render :json => {error: e}
  end

  def update
    post_params = recipe_params
    @recipe = Recipe.find(params[:id])

    steps_to_destroy = (@recipe.steps.map { |step| step.id } - post_params[:steps].map { |step| step[:id] })
    ingredients_to_destroy = (@recipe.ingredients.map { |ingredient| ingredient.id } - post_params[:ingredients].map { |ingredient| ingredient[:id] })

    ActiveRecord::Base.transaction do
      destroy_steps(steps_to_destroy)
      destroy_ingredients(ingredients_to_destroy)

      # save the steps or update steps
      post_params[:steps].each do |step|
        if step[:id]
          old_step = Step.find(step[:id])
          old_step.update!(title: step[:title], body: step[:body], position: step[:position])
        else
          Step.create!(title: step[:title], body: step[:body], position: step[:position], recipe: @recipe)
        end
      end
      # save the ingredients or update ingredients
      post_params[:ingredients].each do |ingredient|
        if ingredient[:id]
          old_ingredient = Ingredient.find(ingredient[:id])
          old_ingredient.update!(name: ingredient[:name], quantity: ingredient[:quantity], measurement: ingredient[:measurement])
        else
          Ingredient.create!(name: ingredient[:name], quantity: ingredient[:quantity], measurement: ingredient[:measurement], recipe: @recipe)
        end
      end
      # save / remove / load the tags
      post_params[:tags].each do |tag|
        t = Tag.find_by value: tag[:value]
        if t
          if @recipe.tags.include? t
            @recipe.tags.destroy t
          else
            @recipe.tags << t
          end
        else
          @recipe.tags << Tag.create!(value: tag[:value])
        end
      end
    end

    redirect_to action: "show", slug: @recipe.slug
  rescue ActiveRecord::RecordInvalid => e
    render :json => {error: e}
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    if @recipe.destroy
      render :json => {message: "recipe deleted"}
    end
  end

  private

  def render_recipe(recipes)
    recipes.to_json(:include => [steps: {:except => [:created_at, :updated_at, :recipe_id]},
                                 ingredients: {:except => [:created_at, :updated_at, :recipe_id]},
                                 tags: {:except => [:created_at, :updated_at, :id]}],
                    :except => [:updated_at])
  end

  def render_search_recipe(recipes)
    recipes.to_json(:include => [tags: {:except => [:id, :created_at, :updated_at, :id]}],
                    :except => [:id, :created_at, :updated_at])
  end

  def destroy_steps(ids)
    ids.each do |id|
      Step.find(id).destroy!
    end
  end

  def destroy_ingredients(ids)
    ids.each do |id|
      Ingredient.find(id).destroy!
    end
  end

  def recipe_params
    params.require(:recipe).permit(:title, :description, :slug, steps: [:id, :title, :body, :position], ingredients: [:id, :name, :quantity, :measurement], tags: [:value])
  end

  def search_params
    params.permit(:query)
  end

end
