class ParentProfile < ApplicationRecord
  belongs_to :user

  validates :gender, inclusion: { in: %w(Homme Femme Autre) }, presence: true
  validates :relationship_to_child, presence: true, inclusion: { in: %w(Père Mère Tuteur Autre) }
  validates :phone_number, presence: true # format: { with: /\A[0-9]+\z/ }
  validates :address, presence: true
  validates :zipcode, presence: true
  validates :city, presence: true
  validates :has_valid_rgpd, acceptance: { accept: true }

  # gender: string, select only one, options: ["homme", "femme", "autre"]
  # relationship_to_child: string
  # phone_number: string, only numeric characters for phone
  # address: string
  # zipcode: string
  # city: string, default: "", not null
  # has_valid_rgpd: boolean, default: false, checkbox
  # has_newsletter: boolean, default: false, checkbox

end
