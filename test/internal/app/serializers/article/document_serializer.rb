# frozen_string_literal: true

class Article
  class DocumentSerializer < ArticleSerializer
    module Single
      def body_as_html
        'body as html'
      end

      def body
        'body!'
      end
    end
  end
end
