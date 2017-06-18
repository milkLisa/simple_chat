class RoomsController < ApplicationController
    before_action :authenticate_user!
    
    def index
        #@current_user = current_user
        #puts "============================"
        #puts current_user
        @users = User.where.not(:id => current_user.id)

        #@conversation = Conversation.where(:sender_id => current_user.id).first
        #@conversation = Conversation.new(:sender_id => current_user.id, :recipient_id => @users.first.id)
        
        #puts "............conversation..................."
        #puts @conversation

        #@messages = Message.all
        #@message = Message.new
        #puts "..............messages................."
        #puts @messages

    end
        
end
