class MembershipDeposit < ApplicationRecord

  belongs_to :manager, class_name: 'User'
  belongs_to :depositor, class_name: 'User'
end
