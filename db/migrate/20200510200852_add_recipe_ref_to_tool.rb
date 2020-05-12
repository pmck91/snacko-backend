class AddRecipeRefToTool < ActiveRecord::Migration[6.0]
  def change
    add_reference :tools, :recipe, null: false, foreign_key: true
  end
end
