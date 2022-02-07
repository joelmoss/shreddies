# frozen_string_literal: true

class MyUserSerializer < Shreddies::Json
  def name
    [subject[:first_name], subject[:last_name]].join(' ')
  end

  module WithLastName
    delegate :last_name, to: :subject
  end
end
