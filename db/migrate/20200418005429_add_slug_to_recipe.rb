class AddSlugToRecipe < ActiveRecord::Migration[6.0]
  def change
    add_column :recipes, "slug", :string
  end
end
