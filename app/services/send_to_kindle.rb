# frozen_string_literal: true

class SendToKindle
  def initialize(receiver: ENV.fetch("EMAIL_RECEIVER"))
    self.receiver = receiver
  end

  def call(document_name, html_content)
    KindleMailer.call(
      receiver,
      document_name,
      html_content.encode(Encoding::ISO_8859_1, invalid: :replace, undef: :replace)
    ).deliver_now
  end

  private

  attr_accessor :receiver
end
