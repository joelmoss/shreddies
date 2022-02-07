# frozen_string_literal: true

class UserSerializer < Shreddies::Json
  delegate :email

  def name
    [subject.first_name, subject.last_name].join(' ')
  end

  module WithLastName
    delegate :last_name, to: :subject
  end

  module WithArticles
    delegate :articles, to: :subject

    def latest_article
      articles.first
    end
  end
end
