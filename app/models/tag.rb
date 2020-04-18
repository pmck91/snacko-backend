class Tag < ApplicationRecord

  has_and_belongs_to_many :tags

  validates :value, presence: true
  validates_uniqueness_of :value
end
