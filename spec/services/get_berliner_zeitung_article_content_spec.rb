# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe GetBerlinerZeitungArticleContent do
  it "scrapes article title" do
    http_client = MockHTTPClient.new("berliner-zeitung-article.html")
    service = GetBerlinerZeitungArticleContent.new(http_client: http_client)
    result = service.call(
      "https://www.berliner-zeitung.de/mensch-metropole/berliner-forscher-bitten-zu-ostern-zur-hasenjagd-li.150204"
    )

    expect(result).to include(
      "Berliner Forscher bitten zu Ostern zur Hasenjagd"
    )
  end

  it "scrapes the leading content" do
    http_client = MockHTTPClient.new("berliner-zeitung-article.html")
    service = GetBerlinerZeitungArticleContent.new(http_client: http_client)
    result = service.call(
      "https://www.berliner-zeitung.de/mensch-metropole/berliner-forscher-bitten-zu-ostern-zur-hasenjagd-li.150204"
    )

    expect(result).to include(
      "Vor allem im Ostteil ist immer öfter der echte Hase zu sehen."
    )
  end

  it "scrapes the rest of the article" do
    http_client = MockHTTPClient.new("berliner-zeitung-article.html")
    service = GetBerlinerZeitungArticleContent.new(http_client: http_client)
    result = service.call(
      "https://www.berliner-zeitung.de/mensch-metropole/berliner-forscher-bitten-zu-ostern-zur-hasenjagd-li.150204"
    )

    expect(result).to include(
      "Hasen sind lernfähig und sehen Menschen in der Stadt nicht als Feinde an"
    )
  end

  it "removes images" do
    http_client = MockHTTPClient.new("berliner-zeitung-article.html")
    service = GetBerlinerZeitungArticleContent.new(http_client: http_client)
    result = service.call(
      "https://www.berliner-zeitung.de/mensch-metropole/berliner-forscher-bitten-zu-ostern-zur-hasenjagd-li.150204"
    )

    expect(result).not_to include("<img")
  end
end
