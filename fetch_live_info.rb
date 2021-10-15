require 'open-uri'
require 'json'

def fetch_live_info(channel_url)
  html = URI.open(channel_url).read
  json_str = html[/ytInitialData = (.*);/,1]
  File.write('intial.json', json_str)
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
        items = item_section_content.dig('shelfRenderer', 'content', 'horizontalListRenderer', 'items') || next
        items.map do |item|
          video_id = item.dig('gridVideoRenderer', 'videoId')
          res = {
            status: :reserved,
            title: item.dig('gridVideoRenderer', 'title', 'simpleText'),
            url: "https://www.youtube.com/watch?v=#{video_id}"
          }
          pp res
          lives << res
        end
      end
    end
  end
  lives
end

if __FILE__ == $0
  pp fetch_live_info(ARGV[0])
end
