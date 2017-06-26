class ApplicationController < ActionController::Base
  require 'twilio-ruby'
  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery with: :exception
  #check_authorization
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message #有例外錯誤時導回首頁
  end

  protected
    
  TWILIO_ACCOUNT_SID = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  TWILIO_AUTH_TOKEN = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:last_name])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:tel])
    update_attrs = [:email, :first_name, :last_name, :tel, :password, :password_confirmation, :current_password]
    devise_parameter_sanitizer.permit :account_update, keys: update_attrs
  end

  def send_message(to_user, message_content, subject)
    subject ||= 'From Simple Chat'
    message_content ||= '您有新訊息喔!'

    # send E-mail
    UserMailer.notify_message(to_user.email, message_content, subject).deliver_later!

    # send SMS
    phone_number = get_number(to_user.tel)

    if !phone_number.nil?
      @client = Twilio::REST::Client.new TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN
      
      @client.messages.create(
          from: '+12345678912',
          to: phone_number,
          body: "[#{subject}]#{message_content}"
      )
    end

    return
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
