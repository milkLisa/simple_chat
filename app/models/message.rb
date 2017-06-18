class Message < ApplicationRecord
    belongs_to :sender, class_name: "User", :foreign_key => "sender_id"
    belongs_to :conversation, class_name: "Conversation", :foreign_key => "conversation_id"#, :optional => true
end
