require "mail_to_hip_chat"
require "mail_to_hip_chat/rack_app"
require "mail_to_hip_chat/message_chutes/airbrake"
require "mail_to_hip_chat/message_chutes/test_email"

app = MailToHipChat::RackApp::Builder.new do |builder|
  builder.secret    = ENV['CLOUDMAILIN_SECRET']
  builder.rooms     = ENV['HIPCHAT_ROOMS']
  builder.api_token = ENV['HIPCHAT_API_TOKEN']
  
  # An included chute to process messages from Airbrake.
  builder.use_chute MailToHipChat::MessageChutes::Airbrake

  # This chute should be removed once you've confirmed your setup works.
  builder.use_chute MailToHipChat::MessageChutes::TestEmail
end.to_app

run app