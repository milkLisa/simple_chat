class Conversation < ApplicationRecord
    belongs_to :sender, class_name: "User", :foreign_key => "sender_id"
    belongs_to :recipient, class_name: "User", :foreign_key => "recipient_id"
    has_many :conversion_messages, class_name: "Message", foreign_key: "conversation_id", :dependent => :destroy

    scope :get_exist_conversation, ->(user_id) { where("sender_id = ? or recipient_id = ?", user_id, user_id) }
end
