class MessagesController < ApplicationController
    require 'twilio-ruby'

    TWILIO_ACCOUNT_SID = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    TWILIO_AUTH_TOKEN = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    
    def create
        @message = Message.create(message_params)
        @conversation = Conversation.find(@message.conversation_id)
        @messages = Message.get_messages(@message.conversation_id)
        @send_unread_messages = Message.get_send_unread_messages(@conversation, current_user.id)
        
        @recipient = User.where("(id in (?, ?) and id != ?)", @conversation.sender_id, @conversation.recipient_id, current_user.id)
        @recipient.each do |recipient|
            # send E-mail
            UserMailer.notify_message(recipient, @message).deliver_later!

            # send SMS
            phone_number = get_number(recipient.tel)

            if !phone_number.nil?
                @client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN
                
                @client.messages.create(
                    from: '+12345678912',
                    to: phone_number,
                    body: '[From Simple Chat] You have new messages!'
                )
            end
        end
    end

    def set_readed
        @message = Message.find(params["message_id"])
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

    def get_number(friendly_name)
        lookup_client = Twilio::REST::LookupsClient.new(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
        begin
            response = lookup_client.phone_numbers.get(friendly_name)
            return response.phone_number #response.phone_number #if invalid, throws an exception. If valid, no problems.
        rescue => e
            return nil
        end
    end

end
