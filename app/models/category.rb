class Category < ApplicationRecord
  has_many :activities
  has_many :coach_categories
  has_many :coaches, through: :coach_categories
end
