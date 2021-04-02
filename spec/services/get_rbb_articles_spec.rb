# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe GetRbbArticles do
  it "gets multiple articles" do
    http_client = MockHTTPClient.new("rbb.xml")
    service = GetRbbArticles.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 57
  end

  it "skips videos" do
    http_client = MockHTTPClient.new("rbb-video-articles.xml")
    service = GetRbbArticles.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 1
    expect(result.first.title).to eq(
      "AfD-Parteitag in Frankfurt (Oder): Teilnehmerzahl bleibt nach Gerichtsentscheid auf 500 begrenzt"
    )
  end
end
