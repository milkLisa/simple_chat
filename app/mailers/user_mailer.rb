class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.notify_message.subject
  #
  default :from => "user mailer <from@example.com>"

  def notify_message(user, message)
      @message = message
      mail(:to => "milk45678@yahoo.com.tw", :subject => "New Message")
  end
end
