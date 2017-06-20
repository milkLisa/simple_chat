class Message < ApplicationRecord
    belongs_to :sender, class_name: "User", :foreign_key => "sender_id"
    belongs_to :conversation, class_name: "Conversation", :foreign_key => "conversation_id"

    scope :get_messages, ->(conversation_id) { where( :conversation_id => conversation_id ).order("created_at ASC") }
    scope :get_unread_by_conversation, ->(conversation_id) { where( :conversation_id => conversation_id, :is_read => false ) }
    scope :get_send_unread_messages, ->(conversations, user_id) { where( :conversation_id => conversations, :is_read => false ).where( :sender_id => user_id ).order("created_at DESC") }
    scope :get_receive_unread_messages, ->(conversations, user_id) { where( :conversation_id => conversations, :is_read => false ).where.not( :sender_id => user_id ).order("created_at DESC") }
end
