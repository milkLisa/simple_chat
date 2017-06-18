require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "notify_message" do
    mail = UserMailer.notify_message
    assert_equal "Notify message", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
