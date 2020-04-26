class ShortRecipeSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  attributes :id, :title, :difficulty, :recipe_url, :image_url

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
   