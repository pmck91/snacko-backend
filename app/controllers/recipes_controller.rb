class RecipesController < ApplicationController

  before_action :authorize_as_admin, only: [:create, :update, :destroy]

  def index
    @recipes = Recipe.all
    paged_recipes = @recipes.paginate(page: params[:page], per_page: params[:per_page])
    render :json => paged_recipes, each_serializer: ShortRecipeSerializer
  end

  def show
    @recipe = Recipe.find_by slug: params[:slug]
    render :json => @recipe
  end

  def metadata
    @recipes = Recipe.all.count
    @tags = Tag.all

    count_per_tag = []
    @tags.each_with_index do |tag, i|
      count_per_tag[i] = {
          tag: tag.value,
          count: tag.recipes.count
      }
    end

    render :json => {count: @recipes, by_tag: count_per_tag}
  end

  def search
    if params[:c]
      @recipes = Recipe.searchWithCategory(params[:q], params[:c])
    else
      @recipes = Recipe.search(params[:q])
    end
    paged_recipes = @recipes.paginate(page: params[:page], per_page: params[:per_page])

    render json: {
        query: params[:q],
        category: params[:c],
        recipes: paged_recipes.map { |recipe| ShortRecipeSerializer.new(recipe) }
    }
  end

  def by_tag
    @tag = Tag.find_by_value(params[:tag])
    @recipes = @tag.recipes
    paged_recipes = @recipes.paginate(page: params[:page], per_page: params[:per_page])
    paginate :json => paged_recipes, each_serializer: ShortRecipeSerializer
  end

  def create
    post_params = recipe_params
    @recipe = {}
    ActiveRecord::Base.transaction do
      @recipe = Recipe.create!(title: post_params[:title],
                               description: post_params[:description],
                               difficulty: post_params[:difficulty],
                               cook_time: post_params[:cook_time],
                               prep_time: post_params[:prep_time],
                               serves: post_params[:serves],
                               slug: post_params[:slug])

      # save the steps
      post_params[:steps].each do |step|
        Step.create!(title: step[:title], body: step[:body], position: step[:position], recipe: @recipe)
      end
      # save the ingredients
      post_params[:ingredients].each do |ingredient|
        Ingredient.create!(name: ingredient[:name], quantity: ingredient[:quantity], measurement: ingredient[:measurement], recipe: @recipe)
      end
      # save the tools
      post_params[:tools].each do |tool|
        Tool.create!(name: tool[:name], recipe: @recipe)
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
      # save the tool or update tool
      post_params[:tools].each do |tool|
        if tool[:id]
          old_tool = Tool.find(tool[:id])
          old_tool.update!(name: tool[:name], recipe: @recipe)
        else
          Tool.create!(name: tool[:name])
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
    params.require(:recipe).permit(:title, :description, :difficulty, :cook_time, :prep_time, :serves, :slug, steps: [:id, :title, :body, :position], ingredients: [:id, :name, :quantity, :measurement], tools: [:name], tags: [:value])
  end

  def search_params
    params.permit(:query)
  end

end
