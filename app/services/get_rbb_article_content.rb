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

    select_useful_content(article)
    article.inner_html
  end

  private

  attr_accessor :http_client

  def select_useful_content(article)
    article.css(".commentarea")&.remove
    article.css(".newSharing")&.remove
    article.css("section.teaserbox")&.remove
    article.css("figure.picture")&.remove

    article.css(".textblock").find do |element|
      element.text.include?("Die Kommentarfunktion wurde am")
    end&.remove
  end
end
