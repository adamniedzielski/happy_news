# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe GetRbbArticleContent do
  it "scrapes article title" do
    http_client = MockHTTPClient.new("rbb-article.html")
    service = GetRbbArticleContent.new(http_client: http_client)
    result = service.call(
      "https://www.rbb24.de/politik/beitrag/2020/11/spd-landesparteitag-vorsitzende-giffey-saleh-wahlergebnisse.html"
    )

    expect(result).to include(
      "Saleh und Giffey sind neues Führungsduo der Berliner SPD"
    )
  end

  it "scrapes important article content" do
    http_client = MockHTTPClient.new("rbb-article.html")
    service = GetRbbArticleContent.new(http_client: http_client)
    result = service.call(
      "https://www.rbb24.de/politik/beitrag/2020/11/spd-landesparteitag-vorsitzende-giffey-saleh-wahlergebnisse.html"
    )

    expect(result).to include(
      "Giffey kündigte zudem an, als Spitzenkandidatin für die Abgeordnetenhauswahl 2021 zur Verfügung zu stehen"
    )
  end

  it "leaves out comments" do
    http_client = MockHTTPClient.new("rbb-article.html")
    service = GetRbbArticleContent.new(http_client: http_client)
    result = service.call(
      "https://www.rbb24.de/politik/beitrag/2020/11/spd-landesparteitag-vorsitzende-giffey-saleh-wahlergebnisse.html"
    )

    expect(result).not_to include(
      "Das mit dem Doktortitel wird wegen der bevorstehenden Wahlen hochgespielt"
    )
  end

  it "does not break when comments are outside article" do
    http_client = MockHTTPClient.new("rbb-article-comments-outside.html")
    service = GetRbbArticleContent.new(http_client: http_client)
    result = service.call(
      "https://www.rbb24.de/panorama/beitrag/2021/01/vier-autos-brennen-in-einer-nacht-in-berlin-friedrichsfelde.html"
    )

    expect(result).to include(
      "Vier Autos brennen in einer Nacht in Berlin-Friedrichsfelde"
    )
  end
end
