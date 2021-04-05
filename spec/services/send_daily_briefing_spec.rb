# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendDailyBriefing do
  it "sends multiple articles to Kindle" do
    get_rbb_articles = instance_double(
      GetRbbArticles,
      call: [
        RSS::Rss::Channel::Item.new(
          link: "https://www.rbb24.de/sport/beitrag/2021/04/fussball-50-jahre-rote-karte-fakten.html",
          pubDate: Time.zone.parse("2021-04-05 12:16")
        ),
        RSS::Rss::Channel::Item.new(
          link: "https://www.rbb24.de/panorama/beitrag/av7/video-fischerinsel-fuenfzig-jahre-kinder-ddr-neubau.html",
          pubDate: Time.zone.parse("2021-04-05 12:10")
        )
      ]
    )

    get_rbb_article_content = instance_double(GetRbbArticleContent)
    allow(get_rbb_article_content).to receive(:call)
      .with("https://www.rbb24.de/sport/beitrag/2021/04/fussball-50-jahre-rote-karte-fakten.html")
      .and_return("Content 1")
    allow(get_rbb_article_content).to receive(:call)
      .with("https://www.rbb24.de/panorama/beitrag/av7/video-fischerinsel-fuenfzig-jahre-kinder-ddr-neubau.html")
      .and_return("Content 2")

    get_berliner_zeitung_articles = instance_double(
      GetBerlinerZeitungArticles,
      call: []
    )

    send_to_kindle = instance_double(SendToKindle, call: nil)

    service = SendDailyBriefing.new(
      get_rbb_articles: get_rbb_articles,
      get_rbb_article_content: get_rbb_article_content,
      get_berliner_zeitung_articles: get_berliner_zeitung_articles,
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
    get_berliner_zeitung_articles = instance_double(
      GetBerlinerZeitungArticles,
      call: []
    )
    send_to_kindle = instance_double(SendToKindle, call: nil)

    service = SendDailyBriefing.new(
      get_rbb_articles: get_rbb_articles,
      get_rbb_article_content: get_rbb_article_content,
      get_berliner_zeitung_articles: get_berliner_zeitung_articles,
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
        RSS::Rss::Channel::Item.new(title: "Something BAD happened", link: "https://www.rbb24.de/sport/beitrag/2021/04/fussball-50-jahre-rote-karte-fakten.html"),
        RSS::Rss::Channel::Item.new(title: "Something good happened", link: "https://www.rbb24.de/panorama/beitrag/av7/video-fischerinsel-fuenfzig-jahre-kinder-ddr-neubau.html")
      ]
    )

    get_rbb_article_content = instance_double(GetRbbArticleContent)
    allow(get_rbb_article_content).to receive(:call)
      .with("https://www.rbb24.de/panorama/beitrag/av7/video-fischerinsel-fuenfzig-jahre-kinder-ddr-neubau.html")
      .and_return("Happy Content")

    get_berliner_zeitung_articles = instance_double(
      GetBerlinerZeitungArticles,
      call: []
    )

    send_to_kindle = instance_double(SendToKindle, call: nil)

    service = SendDailyBriefing.new(
      get_rbb_articles: get_rbb_articles,
      get_rbb_article_content: get_rbb_article_content,
      get_berliner_zeitung_articles: get_berliner_zeitung_articles,
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
        RSS::Rss::Channel::Item.new(description: "Something violence accident", link: "https://www.rbb24.de/sport/beitrag/2021/04/fussball-50-jahre-rote-karte-fakten.html"),
        RSS::Rss::Channel::Item.new(description: "Peace everywhere", link: "https://www.rbb24.de/panorama/beitrag/av7/video-fischerinsel-fuenfzig-jahre-kinder-ddr-neubau.html")
      ]
    )

    get_rbb_article_content = instance_double(GetRbbArticleContent)
    allow(get_rbb_article_content).to receive(:call)
      .with("https://www.rbb24.de/panorama/beitrag/av7/video-fischerinsel-fuenfzig-jahre-kinder-ddr-neubau.html")
      .and_return("Happy Content")

    get_berliner_zeitung_articles = instance_double(
      GetBerlinerZeitungArticles,
      call: []
    )

    send_to_kindle = instance_double(SendToKindle, call: nil)

    service = SendDailyBriefing.new(
      get_rbb_articles: get_rbb_articles,
      get_rbb_article_content: get_rbb_article_content,
      get_berliner_zeitung_articles: get_berliner_zeitung_articles,
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

  it "gets articles from both RBB and Berliner Zeitung" do
    get_rbb_articles = instance_double(
      GetRbbArticles,
      call: [
        RSS::Rss::Channel::Item.new(
          link: "https://www.rbb24.de/sport/beitrag/2021/04/fussball-50-jahre-rote-karte-fakten.html",
          pubDate: Time.zone.parse("2021-04-05 12:16")
        )
      ]
    )

    get_rbb_article_content = instance_double(GetRbbArticleContent)
    allow(get_rbb_article_content).to receive(:call)
      .with("https://www.rbb24.de/sport/beitrag/2021/04/fussball-50-jahre-rote-karte-fakten.html")
      .and_return("RBB Content")

    get_berliner_zeitung_articles = instance_double(
      GetBerlinerZeitungArticles,
      call: [
        RSS::Rss::Channel::Item.new(
          link: "https://www.berliner-zeitung.de/mensch-metropolemensch-metropole/neue-freiheit-li.149745",
          pubDate: Time.zone.parse("2021-04-05 12:10")
        )
      ]
    )

    get_berliner_zeitung_article_content = instance_double(GetBerlinerZeitungArticleContent)
    allow(get_berliner_zeitung_article_content).to receive(:call)
      .with("https://www.berliner-zeitung.de/mensch-metropolemensch-metropole/neue-freiheit-li.149745")
      .and_return("Berliner Zeitung Content")

    send_to_kindle = instance_double(SendToKindle, call: nil)

    service = SendDailyBriefing.new(
      get_rbb_articles: get_rbb_articles,
      get_rbb_article_content: get_rbb_article_content,
      get_berliner_zeitung_articles: get_berliner_zeitung_articles,
      get_berliner_zeitung_article_content: get_berliner_zeitung_article_content,
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
              RBB Content Berliner Zeitung Content
            </body>
          </html>
        HEREDOC
      )
  end

  it "shows latest articles first" do
    get_rbb_articles = instance_double(
      GetRbbArticles,
      call: [
        RSS::Rss::Channel::Item.new(
          link: "https://www.rbb24.de/sport/beitrag/2021/04/fussball-50-jahre-rote-karte-fakten.html",
          pubDate: Time.zone.parse("2021-04-04 18:02")
        )
      ]
    )

    get_rbb_article_content = instance_double(GetRbbArticleContent)
    allow(get_rbb_article_content).to receive(:call)
      .with("https://www.rbb24.de/sport/beitrag/2021/04/fussball-50-jahre-rote-karte-fakten.html")
      .and_return("RBB Content")

    get_berliner_zeitung_articles = instance_double(
      GetBerlinerZeitungArticles,
      call: [
        RSS::Rss::Channel::Item.new(
          link: "https://www.berliner-zeitung.de/mensch-metropolemensch-metropole/neue-freiheit-li.149745",
          pubDate: Time.zone.parse("2021-04-05 12:16")
        )
      ]
    )

    get_berliner_zeitung_article_content = instance_double(GetBerlinerZeitungArticleContent)
    allow(get_berliner_zeitung_article_content).to receive(:call)
      .with("https://www.berliner-zeitung.de/mensch-metropolemensch-metropole/neue-freiheit-li.149745")
      .and_return("Berliner Zeitung Content")

    send_to_kindle = instance_double(SendToKindle, call: nil)

    service = SendDailyBriefing.new(
      get_rbb_articles: get_rbb_articles,
      get_rbb_article_content: get_rbb_article_content,
      get_berliner_zeitung_articles: get_berliner_zeitung_articles,
      get_berliner_zeitung_article_content: get_berliner_zeitung_article_content,
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
              Berliner Zeitung Content RBB Content
            </body>
          </html>
        HEREDOC
      )
  end
end
