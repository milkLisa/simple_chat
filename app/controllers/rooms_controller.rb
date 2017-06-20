class RoomsController < ApplicationController
    before_action :authenticate_user!
    
    def index
        users = User.where.not(:id => current_user.id)
        @unread_messages = Message.get_receive_unread_messages(Conversation.get_exist_conversation(current_user.id), current_user.id)
        @unread_messages_maps = @unread_messages.select("sender_id, count(*) unread_total").group(:sender_id)
        
        @users_array = []
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
