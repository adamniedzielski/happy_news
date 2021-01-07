# frozen_string_literal: true

namespace :briefing do
  task send_daily: :environment do
    SendDailyBriefing.new.call
  end
end
