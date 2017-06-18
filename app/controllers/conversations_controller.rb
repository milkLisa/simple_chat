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
                @messages = Message.where(:conversation_id => @conversation.id).order("created_at ASC")
                @message = Message.new
            else
                show_error_message
            end
        end
    end

    private

    def show_error_message
        flash[:alert] = "please try again later!"

        respond_to do |format|
            format.html root_path
        end
    end
end
