class EscrowMap < ApplicationRecord
    belongs_to :officer, class_name: 'User', :foreign_key => 'officer_id'
    belongs_to :user, class_name: 'User', :foreign_key => 'user_id'
end
