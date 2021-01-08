# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendToKindle do
  it "sends email to magic Kindle address" do
    SendToKindle.new(receiver: "test@kindle.com").call("<b>My article</b>")

    expect(ActionMailer::Base.deliveries.size).to eq 1
    expect(ActionMailer::Base.deliveries.last.to).to eq ["test@kindle.com"]
  end

  it "sends the attachment in ISO-8859-1 encoding" do
    RSpec::Matchers.define :iso_8859_1_encoded do
      match { |actual| actual.encoding == Encoding::ISO_8859_1 }
    end

    service = SendToKindle.new(receiver: "test@kindle.com")

    expect(KindleMailer).to receive(:call)
      .with(anything, iso_8859_1_encoded)
      .and_call_original

    service.call("Üäößß")
  end
end
