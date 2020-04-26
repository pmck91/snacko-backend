class Step < ApplicationRecord

  default_scope { order(position: :asc) }

  belongs_to :recipe

  validates :title, presence: true
  validates :body, presence: true
  validates :position, presence: true

  validates :position, uniqueness: {scope: :recipe, :message => Proc.new { |step, data|
    "for #{step.title} with value '#{data[:value]}' has already been used by another step in the recipe '#{step.recipe.title}'"
  }}

end
