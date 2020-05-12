class RecipeSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  attributes :id, :title, :description, :difficulty, :cook_time, :prep_time, :difficulty, :serves, :recipe_url, :image_url, :created_at

  has_many :steps
  has_many :ingredients
  has_many :tools
  has_many :tags

  def recipe_url
    "/recipes/#{object.slug}"
  end

  def image_url
    if object.image.attached?
      rails_blob_path(object.image, only_path: true)
    else
      ""
    end
  end
end
