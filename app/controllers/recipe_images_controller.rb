class RecipeImagesController < ApplicationController

  def attach
    @recipe = Recipe.find(params[:id])
    @recipe.image.attach(params[:file])
    render json: {status: :ok}
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    if @recipe.image.purge
      render json: {status: :ok}
    else
      render json: {error: "image not deleted"}
    end
  end

  params.permit(:file)
end
