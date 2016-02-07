module SlashDeploy
  class MockSlack
    attr_reader :handler

    def self.start
      new(SlashDeploy::Commands.slack_handler).run
    end

    def initialize(handler)
      @handler = handler
    end

    def run
      loop do
        print "/"
        line = gets
        break unless line
        command, *text = line.split(' ')
        cmd = Slash::Command.from_params(
          command: command,
          text:    text.join(' '),
          token:   Rails.configuration.x.slack.verification_token
        )
        resp = handler.call('cmd' => cmd)
        puts resp.text
      end
    end
  end
end
