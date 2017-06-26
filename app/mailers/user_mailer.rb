class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.notify_message.subject
  #
  default :from => 'user mailer <from@example.com>'

  def notify_message(email, message, subject)
      mail(:to => email, :body => message, :subject => subject)

      render json: nil, status: :ok
  end
end
