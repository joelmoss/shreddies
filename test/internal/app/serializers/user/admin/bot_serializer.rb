# frozen_string_literal: true

class User::Admin::BotSerializer < User::AdminSerializer
  def admin_team
    'bots'
  end
end
