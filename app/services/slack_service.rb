class SlackService
  def initialize(channel_name, message, blocks = nil)
    @channel_name = channel_name
    @message = message
    @blocks = blocks
  end

  def self.notify!(channel_name, message, blocks)
    new(channel_name, message, blocks).notify!
  end

  def notify!
    client.chat_postMessage(channel: channel_name, text: message, blocks: blocks)
  rescue Exception => e
    # Bugsnag isn't catching this unfortunately
    Bugsnag.notify(e)
  end

  private

  attr_reader :channel_name, :message, :blocks

  def client
    @_client ||= Slack::Web::Client.new(token: ENV['SLACK_APP_TOKEN'])
  end
end
