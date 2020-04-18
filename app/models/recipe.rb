class Recipe < ApplicationRecord

  has_many :ingredients, dependent: :destroy
  has_many :steps, dependent: :destroy
  has_and_belongs_to_many :tags

  accepts_nested_attributes_for :ingredients, allow_destroy: true
  accepts_nested_attributes_for :steps, allow_destroy: true

  validates_associated :steps

  validates_uniqueness_of :slug

  validates :title, presence: true
  validates :description, presence: true

end
