# frozen_string_literal: true

class BeforeSerializer < Shreddies::Json
  def name
    [subject[:first_name], subject[:last_name]].join(' ')
  end

  private

  def before_render(data)
    data.tap { |x| x[:middle_name] = 'Kevin' }
  end
end
