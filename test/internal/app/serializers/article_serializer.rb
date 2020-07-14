# frozen_string_literal: true

module ExplicitBody
  def body
    'explicit body'
  end
end

class ArticleSerializer < Shreddies::Json
  delegate :title

  module Collection
    def slug
      send :parameterized_title
    end
  end

  module Single
    def body
      "A really, really long body for #{title}"
    end
  end

  module WithBody
    delegate :subtitle, to: :subject

    def body
      "Some body for #{title}"
    end
  end

  module WithUrl
    def url
      "http://blah/#{parameterized_title}"
    end

    def body
      "Adjusted body for #{title}"
    end
  end

  private

  def parameterized_title
    title.parameterize
  end
end
