class MessagesController < ApplicationController

    def create
        @messages = Message.where(:conversation_id => @message.conversation_id).order("created_at ASC")
        @message = Message.create(message_params)
        @conversation = Conversation.find(@message.conversation_id)
    end

    private

    def message_params
        params.require(:message).permit(:sender_id, :conversation_id, :content)
    end
end
