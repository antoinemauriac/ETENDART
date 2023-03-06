class Location < ApplicationRecord
  belongs_to :academy
  has_many :activities
end
