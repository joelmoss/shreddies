# frozen_string_literal: true

class UserSerializer < Shreddies::Json
  delegate :email

  def name
    [subject.first_name, subject.last_name].join(' ')
  end
end
