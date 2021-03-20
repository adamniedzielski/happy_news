# frozen_string_literal: true

namespace :briefing do
  task send_daily: :environment do
    banned_phrases = ENV.fetch("BANNED_PHRASES").split("|")
    SendDailyBriefing.new.call(banned_phrases: banned_phrases)
  end
end
