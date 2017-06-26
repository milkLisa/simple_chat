class User < ApplicationRecord
  rolify :before_add => :before_add_method
  after_create :assign_default_role
  #enum role: [:system, :admin, :mlo, :escrow, :investor, :borrower]
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :conversations_sender, class_name: 'Conversation', foreign_key: 'sender_id'
  has_many :conversations_recipient, class_name: 'Conversation', foreign_key: 'recipient_id'
  has_many :messages_sender, class_name: 'Message', foreign_key: 'sender_id'
  has_many :escrow_officer, class_name: 'EscrowMap', foreign_key: 'officer_id'
  has_many :escrow_user, class_name: 'EscrowMap', foreign_key: 'user_id'
  
  def before_add_method(role)
    # do something before it gets added

    [:system, :admin, :mlo, :escrow, :investor, :borrower].each do |role|
      Role.find_or_create_by!({ name: role })
    end
  end
  
  def assign_default_role
    if self.roles.blank?
      #if User.with_any_role(:system).size == 0
      #  self.add_role(:system)
      #elsif User.with_any_role(:admin).size == 0
      if User.with_any_role(:admin).size == 0
        self.add_role(:admin)
      else
        self.add_role(:borrower)
      end
    end
  end
  
  def remove_only_role_relation(role_name)
      roles.delete(roles.where(:name => role_name))
  end
end
