# frozen_string_literal: true

class User::AdminSerializer < UserSerializer
  def admin_team
    'devs'
  end
end
