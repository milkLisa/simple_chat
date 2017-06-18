class RoomsController < ApplicationController
    before_action :authenticate_user!
    
    def index
        @users = User.where.not(:id => current_user.id)
        @unread_messages = Message.includes(:conversation).where(:conversation => {:recipient_id => current_user.id}, :is_read => false)
    end
        
end
