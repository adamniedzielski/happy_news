# frozen_string_literal: true

class GetBerlinerZeitungArticleContent
  def initialize(http_client: HTTParty)
    self.http_client = http_client
  end

  def call(url)
    page = Nokogiri::HTML(http_client.get(url).body)

    title = page.at(".a-storyhead")
    leading_content = page.at(".a-storylead")

    content = page.at(".main-content")
    content.css("img")&.remove

    "#{title} #{leading_content} #{content.inner_html}"
  end

  private

  attr_accessor :http_client
end
