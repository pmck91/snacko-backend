class Recipe < ApplicationRecord

  has_many :ingredients, dependent: :destroy
  has_many :steps, dependent: :destroy
  has_many :tools, dependent: :destroy

  has_and_belongs_to_many :tags

  has_one_attached :image

  accepts_nested_attributes_for :ingredients, allow_destroy: true
  accepts_nested_attributes_for :steps, allow_destroy: true

  validates_associated :steps
  validates_associated :tools
  validates_associated :ingredients

  validates_uniqueness_of :slug

  validates :title, presence: true
  validates :description, presence: true
  validates :difficulty, numericality: {greater_than: 0, less_than: 4}
  validates :serves, numericality: {greater_than: 0}
  validates :cook_time, numericality: {greater_than: 0}
  validates :prep_time, numericality: {greater_than: 0}

  def self.search(query)
    key = "%#{query}%"
    Recipe.where('title LIKE :term OR description LIKE :term', term: key).order(:title)
  end

  def self.searchWithCategory(query, category)
    key = "%#{query}%"
    Recipe.joins(:tags).where(tags: {value: category}).where('title LIKE :term OR description LIKE :term', term: key).order(:title)
  end

end
