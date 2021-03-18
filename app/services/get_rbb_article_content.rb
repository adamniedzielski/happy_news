# frozen_string_literal: true

class GetRbbArticleContent
  def initialize(http_client: HTTParty)
    self.http_client = http_client
  end

  def call(url)
    simplified_version_url = "#{url}/print=true"

    page = Nokogiri::HTML(http_client.get(simplified_version_url).body)
    article = page.at("article[role=article]")

    return "" unless article

    article.css(".commentarea")&.remove
    article.css(".newSharing")&.remove
    article.css("section.teaserbox")&.remove
    article.css("figure.picture")&.remove

    article.inner_html
  end

  private

  attr_accessor :http_client
end
