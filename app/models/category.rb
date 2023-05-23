class Category < ApplicationRecord

  validates :super_category, presence: true, inclusion: { in: ['Sport', 'Sport-eveil', 'Eveil', 'Cuisine'] }
  validates :name, presence: true, uniqueness: true

  has_many :activities
  has_many :coach_categories
  has_many :coaches, through: :coach_categories
end
