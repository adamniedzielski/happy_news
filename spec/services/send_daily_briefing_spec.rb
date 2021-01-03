# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendDailyBriefing do
  it "sends multiple articles to Kindle" do
    get_rbb_articles = instance_double(GetRbbArticles, call: [])
    get_rbb_article_content = instance_double(GetRbbArticleContent, call: "")
    send_to_kindle = instance_double(SendToKindle, call: nil)

    service = SendDailyBriefing.new(
      get_rbb_articles: get_rbb_articles,
      get_rbb_article_content: get_rbb_article_content,
      send_to_kindle: send_to_kindle
    )

    service.call

    expect(send_to_kindle).to have_received(:call)
      .with("Content 1 Content 2")
 end
end
