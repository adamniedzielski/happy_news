# frozen_string_literal: true

class KindleMailer < ApplicationMailer
  def call(receiver, html_content)
    attachments["book.html"] = html_content
    mail(to: receiver) do |format|
      format.text { "" }
    end
  end
end
