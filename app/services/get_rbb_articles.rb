# frozen_string_literal: true

class GetRbbArticles
  URL = "https://www.rbb24.de/aktuell/index.xml/feed=rss.xml"

  def initialize(http_client: HTTParty)
    self.http_client = http_client
  end

  def call
    feed = RSS::Parser.parse(http_client.get(URL).body)

    articles = feed.items
    reject_videos(articles)
  end

  private

  attr_accessor :http_client

  def reject_videos(articles)
    articles.reject do |article|
      article.title.start_with?("Video")
    end
  end
end
