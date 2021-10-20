require 'yaml'
require_relative 'fetch_live_info'

target_channels = YAML.load(File.read 'target_channel.yml')
target_channels.each do |channel_name, channel_url|
  puts "chahhel_url: #{channel_url}. #{Time.now}"
  sleep 1
  lives = fetch_live_info(channel_url)
  lives.each do |live|
    next if live[:start_time] > (Time.now+3600*12)
    next if `ps -ax | grep wait_youtubu_live.sh`.include?(live[:url])
    p live
    `/bin/bash alert_line.sh #{channel_name}のライブが検知されました。 #{live[:url]}`
    Thread.new do 
      `/bin/bash wait_youtubu_live.sh #{live[:url]} > logs/wait_youtube_live_#{live[:id]}.log 2>&1`
    end
  end
rescue => e
  puts "#{e.message}. #{Time.now}"
  p e.backtrace
  `/bin/bash alert_line.sh #{e.message}`
end
