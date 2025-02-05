require 'open-uri'
require 'json'
require 'nokogiri'

def fetch_live_info(channel_url)
  html = URI.open(channel_url).read
  doc = Nokogiri::HTML.parse(html)
  script = doc.at_css('script:contains("ytInitialData")').text
  json_str = script[/ytInitialData = (.*);/,1]
  ytInitialData = JSON.parse(json_str)
  tabs = ytInitialData.dig('contents', 'twoColumnBrowseResultsRenderer', 'tabs')
  lives = []
  tabs.each do |tab|
    section_list_contents = tab.dig('tabRenderer', 'content', 'sectionListRenderer', 'contents') || next
    section_list_contents.each do |section_list_content|
      item_section_content = section_list_content.dig('itemSectionRenderer', 'contents')&.first
      item_section_title = item_section_content.dig('shelfRenderer', 'title', 'runs')&.first&.dig('text') || next
      # puts item_section_title
      if item_section_title == 'Upcoming live streams'
        if items =  item_section_content.dig('shelfRenderer', 'content', 'expandedShelfContentsRenderer', 'items')
          items.map do |item|
            video_id = item.dig('videoRenderer', 'videoId')
            res = {
              id: video_id,
              status: :reserved,
              title: item.dig('videoRenderer', 'title', 'simpleText'),
              url: "https://www.youtube.com/watch?v=#{video_id}",
              start_time: Time.at(item.dig('videoRenderer', 'upcomingEventData', 'startTime').to_i)
            }
            lives << res
          end
        elsif items = item_section_content.dig('shelfRenderer', 'content', 'horizontalListRenderer', 'items')
          items.map do |item|
            video_id = item.dig('gridVideoRenderer', 'videoId')
            res = {
              id: video_id,
              status: :reserved,
              title: item.dig('gridVideoRenderer', 'title', 'simpleText'),
              url: "https://www.youtube.com/watch?v=#{video_id}",
              start_time: Time.at(item.dig('gridVideoRenderer', 'upcomingEventData', 'startTime').to_i)
            }
            lives << res
          end
        end
      end
    end
  end
  lives
end

if __FILE__ == $0
  pp fetch_live_info(ARGV[0])
end
