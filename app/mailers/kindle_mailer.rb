# frozen_string_literal: true

class KindleMailer < ApplicationMailer
  def call(receiver, document_name, html_content)
    attachments["#{document_name}.html"] = html_content
    mail(to: receiver) do |format|
      format.text { "" }
    end
  end
end
