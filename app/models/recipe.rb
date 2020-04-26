class Recipe < ApplicationRecord

  attribute :cooking_duration, :duration

  enum difficulty: [:ez_peazy, :easy_enough, :grand, :tough, :hard_as_nails]

  has_many :ingredients, dependent: :destroy
  has_many :steps, dependent: :destroy
  has_and_belongs_to_many :tags

  has_one_attached :image

  accepts_nested_attributes_for :ingredients, allow_destroy: true
  accepts_nested_attributes_for :steps, allow_destroy: true

  validates_associated :steps

  validates_uniqueness_of :slug

  validates :title, presence: true
  validates :description, presence: true

  def self.search(query)
    key = "%#{query}%"
    Recipe.where('title LIKE :term OR description LIKE :term', term: key).order(:title)
  end

end
