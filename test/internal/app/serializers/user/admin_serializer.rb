# frozen_string_literal: true

class User
  class AdminSerializer < UserSerializer
    def admin_team
      'devs'
    end
  end
end
