# frozen_string_literal: true

class SendDailyBriefing
  # rubocop:disable Metrics/ParameterLists
  def initialize(
    banned_phrases:, get_rbb_articles: GetRbbArticles.new,
    get_rbb_article_content: GetRbbArticleContent.new,
    get_berliner_zeitung_articles: GetBerlinerZeitungArticles.new,
    get_berliner_zeitung_article_content: GetBerlinerZeitungArticleContent.new,
    send_to_kindle: SendToKindle.new
  )
    self.banned_phrases = banned_phrases
    self.get_rbb_articles = get_rbb_articles
    self.get_rbb_article_content = get_rbb_article_content
    self.get_berliner_zeitung_articles = get_berliner_zeitung_articles
    self.get_berliner_zeitung_article_content = get_berliner_zeitung_article_content
    self.send_to_kindle = send_to_kindle
  end
  # rubocop:enable Metrics/ParameterLists

  def call
    articles = get_rbb_articles.call + get_berliner_zeitung_articles.call
    happy_articles = reject_unhappy(articles)

    body = happy_articles.map do |article|
      get_content(article)
    end.join(" ")

    document_name = "Happy Briefing #{Time.current.strftime('%d.%m')}"
    send_to_kindle.call(document_name, format_document(body))
  end

  private

  attr_accessor(
    :banned_phrases, :get_rbb_articles, :get_rbb_article_content,
    :get_berliner_zeitung_articles, :get_berliner_zeitung_article_content,
    :send_to_kindle
  )

  def reject_unhappy(articles)
    articles.reject do |article|
      banned_phrases.any? do |phrase|
        "#{article.title} #{article.description}".downcase.include?(phrase)
      end
    end
  end

  def get_content(article)
    if article.link.start_with?("https://www.rbb24.de")
      get_rbb_article_content.call(article.link)
    else
      get_berliner_zeitung_article_content.call(article.link)
    end
  end

  def format_document(body)
    <<~HEREDOC
      <!DOCTYPE html>
      <html lang="en">
        <head></head>
        <body>
          #{body}
        </body>
      </html>
    HEREDOC
  end
end
