desc "Starts up an interactive fake Slack channel to type slash commands"
task slack: :environment do
  ARGV.clear
  SlashDeploy::MockSlack.start
end
