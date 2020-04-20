class RecipeSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  attributes :id, :title, :description, :recipe_url

  has_many :steps
  has_many :ingredients
  has_many :tags

  def recipe_url
    "/recipes/#{object.slug}"
  end

  def image_url
    rails_blob_path(object.image, only_path: true)
  end
end
