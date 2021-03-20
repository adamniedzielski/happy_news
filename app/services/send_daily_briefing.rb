# frozen_string_literal: true

class SendDailyBriefing
  def initialize(
    banned_phrases:, get_rbb_articles: GetRbbArticles.new,
    get_rbb_article_content: GetRbbArticleContent.new,
    send_to_kindle: SendToKindle.new
  )
    self.get_rbb_articles = get_rbb_articles
    self.get_rbb_article_content = get_rbb_article_content
    self.send_to_kindle = send_to_kindle
    self.banned_phrases = banned_phrases
  end

  def call
    articles = get_rbb_articles.call
    happy_articles = reject_unhappy(articles)

    body = happy_articles.map do |article|
      get_rbb_article_content.call(article.link)
    end.join(" ")

    document_name = "Happy Briefing #{Time.current.strftime('%d.%m')}"
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

    send_to_kindle.call(document_name, document)
  end

  private

  attr_accessor :get_rbb_articles, :get_rbb_article_content, :send_to_kindle, :banned_phrases

  def reject_unhappy(articles)
    articles.reject do |article|
      banned_phrases.any? do |phrase|
        "#{article.title} #{article.description}".downcase.include?(phrase)
      end
    end
  end
end
