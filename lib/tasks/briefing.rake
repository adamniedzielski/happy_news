# frozen_string_literal: true

namespace :briefing do
  task send_daily: :environment do
    banned_phrases = ENV.fetch("BANNED_PHRASES").split("|")
    SendDailyBriefing.new(banned_phrases: banned_phrases).call
  end
end
