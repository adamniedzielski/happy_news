# frozen_string_literal: true

class SendDailyBriefing
  def initialize(
    get_rbb_articles: GetRbbArticles.new,
    get_rbb_article_content: GetRbbArticleContent.new,
    send_to_kindle: SendToKindle.new
  )
    self.get_rbb_articles = get_rbb_articles
    self.get_rbb_article_content = get_rbb_article_content
    self.send_to_kindle = send_to_kindle
  end

  def call
    body = get_rbb_articles.call.map do |article|
      get_rbb_article_content.call(article.link)
    end.join(" ")

    document =
      <<~HEREDOC
        <!DOCTYPE html>
        <html lang="en">
          <head></head>
          <body>
            #{body}
          </body>
        </html>
      HEREDOC

    send_to_kindle.call("Happy Briefing", document)
  end

  private

  attr_accessor :get_rbb_articles, :get_rbb_article_content, :send_to_kindle
end
