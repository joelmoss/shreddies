# frozen_string_literal: true

class User::AdminSerializer < UserSerializer
  def type
    :admin
  end
end
