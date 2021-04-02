# frozen_string_literal: true

class GetBerlinerZeitungArticles
  URL = "https://www.berliner-zeitung.de/feed.id_mensch_und_metropole.xml"

  def initialize(http_client: HTTParty)
    self.http_client = http_client
  end

  def call
    feed = RSS::Parser.parse(http_client.get(URL).body)
    feed.items
  end

  private

  attr_accessor :http_client
end
