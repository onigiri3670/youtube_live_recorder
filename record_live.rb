require 'yaml'
require_relative 'fetch_live_info'

target_channels = YAML.load(File.read 'target_channel.yml')
target_channels.each do |cnannel_name, channel_url|
  sleep 1
  lives = fetch_live_info(channel_url)
  lives.each do |live|
    next if `ps -ax | grep wait_youtubu_live.sh`.include?(live[:url])
    fork do
      `/bin/bash wait_youtubu_live.sh #{live[:url]} > logs/wait_youtube_live_#{live[:id]}.log 2>&1`
    end
  end
end
