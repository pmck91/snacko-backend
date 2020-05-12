class AddDifficultyPrepCookAndServesToRecipe < ActiveRecord::Migration[6.0]
  def change

    add_column :recipes, :difficulty, :integer
    add_column :recipes, :cook_time, :integer
    add_column :recipes, :prep_time, :integer
    add_column :recipes, :serves, :integer
  end
end
