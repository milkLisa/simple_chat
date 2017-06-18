class ConversationsController < ApplicationController

    def new
        if current_user.nil? || User.find(params[:id]).nil?
            show_error_message
        else
            @conversation = Conversation.where(:sender_id => params[:id], :recipient_id => current_user.id).first

            if @conversation.nil?
                @conversation = Conversation.where(:sender_id => current_user.id, :recipient_id => params[:id]).first_or_create
            end

            if !@conversation.nil?
                #set unread message status to readed
                Message.where(:conversation_id => @conversation.id, :is_read => false).where.not(:sender_id =>current_user.id).update_all(:is_read => true)
                @messages = Message.where(:conversation_id => @conversation.id).order("created_at ASC")#.last(10)
                @message = Message.new
            else
                show_error_message
            end
        end
    end

    private

    def show_error_message
        flash[:alert] = "Please try again later!"
        redirect_to root_path
    end
end
