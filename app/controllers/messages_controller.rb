class MessagesController < ApplicationController

    def create
        @message = Message.create(message_params)
        @conversation = Conversation.find(@message.conversation_id)
        @messages = Message.where(:conversation_id => @message.conversation_id).order("created_at ASC")#.last(10)
    end

    private

    def message_params
        params.require(:message).permit(:sender_id, :conversation_id, :content)
    end
end
