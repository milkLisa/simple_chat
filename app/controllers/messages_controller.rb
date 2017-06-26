class MessagesController < ApplicationController
    load_and_authorize_resource

    def create
        @message = Message.create(message_params)
        @conversation = Conversation.find(@message.conversation_id)
        @messages = Message.get_messages(@message.conversation_id)
        @send_unread_messages = Message.get_send_unread_messages(@conversation, current_user.id)
        
        @recipient = User.where('(id in (?, ?) and id != ?)', @conversation.sender_id, @conversation.recipient_id, current_user.id)
        @recipient.each do |recipient|
            send_message(recipient, nil, nil)
        end
    end

    def set_readed
        @message = Message.find(params['message_id'])
        @message.update(:is_read => true)
        @conversation = Conversation.find(@message.conversation_id)
        @messages = Message.get_messages(@message.conversation_id)

        respond_to do |format|
            format.js {render file: '/messages/append_message.js.erb'}
        end
    end

    def get_unread
        @unread_messages = Message.get_receive_unread_messages(Conversation.get_exist_conversation(current_user.id), current_user.id)
        
        respond_to do |format|
            format.js {render file: '/messages/update_unread.js.erb'}
        end
    end

    private

    def message_params
        params.require(:message).permit(:sender_id, :conversation_id, :content)
    end
end
