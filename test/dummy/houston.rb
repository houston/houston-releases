# Load Houston
require "houston/application"

# Configure Houston
Houston.config do

  # Houston should load config/database.yml from this module
  # rather than from Houston Core.
  root Pathname.new File.expand_path("../../..",  __FILE__)

  # Give dummy values to these required fields.
  host "houston.test.com"
  secret_key_base "7cbfdc509ec2fb15f68dfccc968a9d"
  mailer_sender "houston@test.com"

  # Mount this module on the dummy Houston application.
  use :releases do
    change_tags( {name: "New Feature", as: "feature", color: "8DB500"},
                 {name: "Improvement", as: "improvement", color: "3383A8", aliases: %w{enhancement}},
                 {name: "Bugfix", as: "fix", color: "C64537", aliases: %w{bugfix}} )
  end

end
