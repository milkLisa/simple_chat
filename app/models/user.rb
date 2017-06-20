class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :conversations_sender, class_name: "Conversation", foreign_key: "sender_id"
  has_many :conversations_recipient, class_name: "Conversation", foreign_key: "recipient_id"
  has_many :messages_sender, class_name: "Message", foreign_key: "sender_id"
end
