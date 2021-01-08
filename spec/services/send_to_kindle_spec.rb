# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendToKindle do
  it "sends email to magic Kindle address" do
    service = SendToKindle.new(receiver: "test@kindle.com")
    service.call("Happy Briefing 08.01", "<b>My article</b>")

    expect(ActionMailer::Base.deliveries.size).to eq 1
    expect(ActionMailer::Base.deliveries.last.to).to eq ["test@kindle.com"]
  end

  it "sends the attachment in ISO-8859-1 encoding" do
    RSpec::Matchers.define :iso_8859_1_encoded do
      match { |actual| actual.encoding == Encoding::ISO_8859_1 }
    end

    service = SendToKindle.new(receiver: "test@kindle.com")

    expect(KindleMailer).to receive(:call)
      .with(anything, "Happy Briefing 08.01", iso_8859_1_encoded)
      .and_call_original

    service.call("Happy Briefing 08.01", "Üäößß")
  end

  it "passes the document name" do
    service = SendToKindle.new(receiver: "test@kindle.com")
    service.call("Happy Briefing 08.01", "<b>My article</b>")

    email = ActionMailer::Base.deliveries.last
    expect(email.attachments.first.filename).to eq "Happy Briefing 08.01.html"
  end
end
