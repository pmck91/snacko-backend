class Tag < ApplicationRecord

  has_and_belongs_to_many :recipes

  validates :value, presence: true
  validates_uniqueness_of :value
end
