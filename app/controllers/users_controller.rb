class UsersController < ApplicationController
    load_and_authorize_resource :only => [:show, :update]

    def show
        if can? :manage, :all
            @roles = Role.where.not('name = ? or name = ?', 'system', current_user.roles.first.name).order('id ASC')
            
            if @user.has_any_role?(:investor, :borrower)
                @escrow_users = User.with_any_role(:escrow)
                @escrow_users.unshift(User.new(:id => 0, :first_name => 'None', :last_name => ''))

                assigned_escrow = EscrowMap.where(:user_id => @user.id)
                @current_officer = User.find(assigned_escrow.first.officer_id) if assigned_escrow.size > 0
            end
        end
    end

    def update
        result = true
        change_password = false
        if !params[:user][:password].blank?
            result = check_password
            change_password = true
        end

        if can?(:manage, :all)
            old_user = @user.dup
            admin_users = User.with_any_role(:admin)
        end

        #build message content for E-mail and SMS
        message_title = "Dear _name_"
        message_content = ""
        message_content += ", _possessive_ email has changed from #{@user.email} to #{params[:user][:email]}" if @user.email != params[:user][:email]
        message_content += ", _possessive_ first name has changed from #{@user.first_name} to #{params[:user][:first_name]}" if @user.first_name != params[:user][:first_name]
        message_content += ", _possessive_ last name has changed from #{@user.last_name} to #{params[:user][:last_name]}" if @user.last_name != params[:user][:last_name]
        message_content += ", _possessive_ telephone has changed from #{@user.tel} to #{params[:user][:tel]}" if @user.tel != params[:user][:tel]
        message_content += ", _possessive_ password has changed"  if change_password

        message_assign = ""
        message_modify_user = ""
        message_modify_user = " by #{current_user.first_name.capitalize}(#{current_user.roles.first.name.capitalize})" if current_user.id != @user.id

        #update user profile
        if result
            update_result = @user.update(user_params(change_password))

            if update_result
                if can? :manage, :all
                    #update user role
                    assigned_role = @user.roles.first.name
                    new_role = Role.find(params[:role]).name
                    if !new_role.nil? && assigned_role != new_role
                        @user.remove_only_role_relation(assigned_role)
                        #@user.remove_role assigned_role
                        @user.add_role new_role
                        message_content += ", _pronouns_ has been assigned as a #{new_role.upcase}"
                    end

                    #update escrow assign
                    assigned_escrow = EscrowMap.where(:user_id => @user.id).first
                    new_escrow = Integer(params[:assign_escrow]) if !params[:assign_escrow].nil?
                    if !new_escrow.nil?
                        if new_escrow == 0 && !assigned_escrow.nil?
                            assigned_escrow.delete
                        elsif new_escrow != 0 && (assigned_escrow.nil? || (!assigned_escrow.nil? && assigned_escrow.officer_id != new_escrow))
                            assigned_escrow = EscrowMap.create(:officer_id => new_escrow, :user_id => @user.id) if assigned_escrow.nil?
                            assigned_escrow.update(:officer_id => new_escrow) if !assigned_escrow.nil? && assigned_escrow.officer_id != new_escrow

                            # send E-mail to Escrow Officer
                            msg_content = "Dear Escrow Officer #{assigned_escrow.officer.first_name.capitalize}, you have been assigned a new contact, #{@user.first_name.capitalize},"
                            msg_content += message_modify_user
                            send_message(assigned_escrow.officer, msg_content, nil)

                            # E-mail to Admins
                            message_assign = ", _pronouns_ has been assigned to Escrow Officer #{assigned_escrow.officer.first_name.capitalize}"
                        end
                    end
                end

                if !message_content.empty?
                    # send E-mail to User
                    msg_content = message_title.gsub("_name_", "#{old_user.first_name.capitalize}")
                    msg_content += message_content.gsub("_possessive_", "your").gsub("_pronouns_", "you")
                    msg_content += message_modify_user
                    send_message(old_user, msg_content, nil)

                    # send E-mail to Admins
                    msg_content = message_title.gsub("_name_", "Admin")
                    msg_content += message_content.sub("_possessive_", "user #{old_user.first_name.capitalize}'s").gsub("_possessive_", "and").gsub("_pronouns_", "user #{old_user.first_name.capitalize}")
                    msg_content += message_assign.gsub("_pronouns_", "user #{old_user.first_name.capitalize}")
                    msg_content += message_modify_user
                    admin_users.each do |user|
                        send_message(user, msg_content, nil)
                    end
                end

                flash[:notice] = "Update successful!"
            else
                flash[:alert] = "Some errors prohibited from being saved"
            end
        end

        redirect_to root_path
    end

    private

    def user_params(result)
        if result
            params.require(:user).permit(:email, :first_name, :last_name, :tel, :password, :password_confirmation)
        else
            params.require(:user).permit(:email, :first_name, :last_name, :tel)
        end
    end

    def check_password
        if params[:user][:password] == params[:user][:password_confirmation]
            if current_user.id == @user.id 
                if params[:user][:current_password].nil?
                    flash[:alert] = "Current password can't be blank"
                    return false
                elsif !@user.valid_password?(params[:user][:current_password])
                    flash[:alert] = "Current password doesn't match"
                    return false
                end
            end
        else
            flash[:alert] = "Confirmation password doesn't match"
            return false
        end

        return true
    end
    
end
