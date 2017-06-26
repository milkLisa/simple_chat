class RoomsController < ApplicationController
    before_action :authenticate_user!
    
    def index
        if can?(:manage, :all) || current_user.has_role?(:mlo)
            users = User.where.not(:id => current_user.id)
        elsif current_user.has_role?(:escrow)
            escrow_users = EscrowMap.select('user_id').where(:officer_id => current_user.id)
            users = User.where(:id => escrow_users ) + User.find(get_conversation_users(current_user.id))
            users = users.uniq
        else
            users = User.find(get_conversation_users(current_user.id))
        end
        @unread_messages = Message.get_receive_unread_messages(Conversation.get_exist_conversation(current_user.id), current_user.id)
        @unread_messages_maps = @unread_messages.select('sender_id, count(*) unread_total').group(:sender_id)
        
        @users_array = []
        if !users.nil?
            users.each do |user| 
                @users_map = {:user => user, :unread_message_count => 0}
                
                @unread_messages_maps.each do |unread_message| 
                    if unread_message.sender_id == user.id
                        @users_map[:unread_message_count] = unread_message.unread_total
                    end
                end

                @users_array << @users_map
            end
        end
    end

    private

    def get_conversation_users(user_id)
        conversation_users = []
        exist_conversations = Conversation.get_exist_conversation(user_id)
        all_ids = exist_conversations.select("sender_id id") + exist_conversations.select("recipient_id id")

        all_ids = all_ids.uniq{|x| x.id}
        all_ids.each do |conversation|
            if conversation.id != user_id
                conversation_users << conversation.id
            end
        end
        return conversation_users
    end

end
