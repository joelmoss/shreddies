# frozen_string_literal: true

class User
  class Admin
    class BotSerializer < User::AdminSerializer
      def admin_team
        'bots'
      end
    end
  end
end
