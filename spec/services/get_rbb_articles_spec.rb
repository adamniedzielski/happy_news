# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe GetRbbArticles do
  it "gets multiple apartments" do
    http_client = MockHTTPClient.new("rbb.xml")
    service = GetRbbArticles.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 60
  end
end
