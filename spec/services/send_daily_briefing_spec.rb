# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendDailyBriefing do
  it "sends multiple articles to Kindle" do
    get_rbb_articles = instance_double(
      GetRbbArticles,
      call: [
        RSS::Rss::Channel::Item.new(link: "link-1"),
        RSS::Rss::Channel::Item.new(link: "link-2")
      ]
    )

    get_rbb_article_content = instance_double(GetRbbArticleContent)
    allow(get_rbb_article_content).to receive(:call)
      .with("link-1").and_return("Content 1")
    allow(get_rbb_article_content).to receive(:call)
      .with("link-2").and_return("Content 2")

    send_to_kindle = instance_double(SendToKindle, call: nil)

    service = SendDailyBriefing.new(
      get_rbb_articles: get_rbb_articles,
      get_rbb_article_content: get_rbb_article_content,
      send_to_kindle: send_to_kindle
    )

    service.call

    expect(send_to_kindle).to have_received(:call)
      .with(
        "Happy Briefing",
        <<~HEREDOC
          <!DOCTYPE html>
          <html lang="en">
            <head></head>
            <body>
              Content 1 Content 2
            </body>
          </html>
        HEREDOC
      )
  end
end
