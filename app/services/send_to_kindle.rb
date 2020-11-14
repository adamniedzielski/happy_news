# frozen_string_literal: true

class SendToKindle
  def initialize(receiver: ENV.fetch("EMAIL_RECEIVER"))
    self.receiver = receiver
  end

  def call(html_content)
    KindleMailer.call(receiver, html_content).deliver_now
  end

  private

  attr_accessor :receiver
end
