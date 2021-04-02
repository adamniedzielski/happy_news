# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe GetBerlinerZeitungArticles do
  it "gets multiple articles" do
    http_client = MockHTTPClient.new("berliner-zeitung.xml")
    service = GetBerlinerZeitungArticles.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 50
    expect(result.first.title).to eq(
      "Ist es okay, sich über eine Impfeinladung zu freuen?"
    )
  end
end
