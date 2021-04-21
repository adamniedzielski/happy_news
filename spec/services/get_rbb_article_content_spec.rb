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

  it "leaves out the notice about comments when comments are closed" do
    http_client = MockHTTPClient.new("rbb-article-closed-comments.html")
    service = GetRbbArticleContent.new(http_client: http_client)
    result = service.call(
      "https://www.rbb24.de/politik/beitrag/2021/04/fragen-antworten-mietendeckel-aus-nachzahlungen.html"
    )

    expect(result).to include("Wer ist von dem Beschluss des Bundesverfassungsgerichts betroffen?")
    expect(result).not_to include("Wir schließen die Kommentarfunktion")
  end

  it "skips overview articles" do
    http_client = MockHTTPClient.new("rbb-article-overview.html")
    service = GetRbbArticleContent.new(http_client: http_client)
    result = service.call(
      "https://www.rbb24.de/panorama/thema/2020/coronavirus/hilfsuebersicht-themenmodul-userfragen.html"
    )

    expect(result).to eq ""
  end

  it "removes the social sharing section" do
    http_client = MockHTTPClient.new("rbb-article.html")
    service = GetRbbArticleContent.new(http_client: http_client)
    result = service.call(
      "https://www.rbb24.de/politik/beitrag/2020/11/spd-landesparteitag-vorsitzende-giffey-saleh-wahlergebnisse.html"
    )

    expect(result).not_to include("bei Facebook teilen")
  end

  it "removes the section with related articles" do
    http_client = MockHTTPClient.new("rbb-article.html")
    service = GetRbbArticleContent.new(http_client: http_client)
    result = service.call(
      "https://www.rbb24.de/politik/beitrag/2020/11/spd-landesparteitag-vorsitzende-giffey-saleh-wahlergebnisse.html"
    )

    expect(result).not_to include("Franziska Giffey in der Glaubwürdigkeitsfalle")
  end

  it "removes photos" do
    http_client = MockHTTPClient.new("rbb-article.html")
    service = GetRbbArticleContent.new(http_client: http_client)
    result = service.call(
      "https://www.rbb24.de/politik/beitrag/2020/11/spd-landesparteitag-vorsitzende-giffey-saleh-wahlergebnisse.html"
    )

    expect(result).not_to include("imago images/Stefan Zeitz")
  end
end
