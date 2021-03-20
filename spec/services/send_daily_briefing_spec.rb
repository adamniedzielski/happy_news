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
      send_to_kindle: send_to_kindle,
      banned_phrases: []
    )

    service.call

    expect(send_to_kindle).to have_received(:call)
      .with(
        anything,
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

  it "includes current date in the document name" do
    get_rbb_articles = instance_double(GetRbbArticles, call: [])
    get_rbb_article_content = instance_double(GetRbbArticleContent, call: "")
    send_to_kindle = instance_double(SendToKindle, call: nil)

    service = SendDailyBriefing.new(
      get_rbb_articles: get_rbb_articles,
      get_rbb_article_content: get_rbb_article_content,
      send_to_kindle: send_to_kindle,
      banned_phrases: []
    )

    travel_to(Time.zone.parse("2021-01-09")) do
      service.call
    end

    expect(send_to_kindle).to have_received(:call).with(
      "Happy Briefing 09.01",
      anything
    )
  end

  it "filters out unhappy articles based on title" do
    get_rbb_articles = instance_double(
      GetRbbArticles,
      call: [
        RSS::Rss::Channel::Item.new(title: "Something BAD happened", link: "link-1"),
        RSS::Rss::Channel::Item.new(title: "Something good happened", link: "link-2")
      ]
    )

    get_rbb_article_content = instance_double(GetRbbArticleContent)
    allow(get_rbb_article_content).to receive(:call)
      .with("link-2").and_return("Happy Content")

    send_to_kindle = instance_double(SendToKindle, call: nil)

    service = SendDailyBriefing.new(
      get_rbb_articles: get_rbb_articles,
      get_rbb_article_content: get_rbb_article_content,
      send_to_kindle: send_to_kindle,
      banned_phrases: ["bad"]
    )

    service.call

    expect(send_to_kindle).to have_received(:call)
      .with(
        anything,
        <<~HEREDOC
          <!DOCTYPE html>
          <html lang="en">
            <head></head>
            <body>
              Happy Content
            </body>
          </html>
        HEREDOC
      )
  end

  it "filters out unhappy articles based on description" do
    get_rbb_articles = instance_double(
      GetRbbArticles,
      call: [
        RSS::Rss::Channel::Item.new(description: "Something violence accident", link: "link-1"),
        RSS::Rss::Channel::Item.new(description: "Peace everywhere", link: "link-2")
      ]
    )

    get_rbb_article_content = instance_double(GetRbbArticleContent)
    allow(get_rbb_article_content).to receive(:call)
      .with("link-2").and_return("Happy Content")

    send_to_kindle = instance_double(SendToKindle, call: nil)

    service = SendDailyBriefing.new(
      get_rbb_articles: get_rbb_articles,
      get_rbb_article_content: get_rbb_article_content,
      send_to_kindle: send_to_kindle,
      banned_phrases: ["violence"]
    )

    service.call

    expect(send_to_kindle).to have_received(:call)
      .with(
        anything,
        <<~HEREDOC
          <!DOCTYPE html>
          <html lang="en">
            <head></head>
            <body>
              Happy Content
            </body>
          </html>
        HEREDOC
      )
  end
end
