class AddRecipeRefToStep < ActiveRecord::Migration[6.0]
  def change
    add_reference :steps, :recipe, null: false, foreign_key: true
  end
end
