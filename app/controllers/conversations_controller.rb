class ConversationsController < ApplicationController
    load_and_authorize_resource
    
    def new
        if current_user.nil? || User.find(params[:id]).nil?
            show_error_message
        else
            @conversation = Conversation.where(:sender_id => params[:id], :recipient_id => current_user.id).first

            if can?(:manage, :all) || current_user.has_any_role?(:mlo, :escrow)
                if @conversation.nil?
                    @conversation = Conversation.where(:sender_id => current_user.id, :recipient_id => params[:id]).first_or_create
                end
            end

            if !@conversation.nil?
                #set unread message status to readed
                @messages = Message.get_messages(@conversation.id)
                @messages.where.not(:sender_id =>current_user.id).update_all(:is_read => true)
                @messages.reload
                @message = Message.new

                @unread_messages = Message.get_receive_unread_messages(Conversation.get_exist_conversation(current_user.id), current_user.id)
            else
                show_error_message
            end
        end
    end

    private

    def show_error_message
        flash[:alert] = 'Please contact the system administrator!'
        redirect_to root_path
    end
end
