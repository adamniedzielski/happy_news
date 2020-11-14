# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendToKindle do
  it "sends email to magic Kindle address" do
    SendToKindle.new(receiver: "test@kindle.com").call("<b>My article</b>")

    expect(ActionMailer::Base.deliveries.size).to eq 1
    expect(ActionMailer::Base.deliveries.last.to).to eq ["test@kindle.com"]
  end
end
