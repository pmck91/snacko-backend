class TagSerializer < ActiveModel::Serializer
  attributes :value, :tag_url

  def tag_url
    "/recipes/category/#{object.value}"
  end
end
