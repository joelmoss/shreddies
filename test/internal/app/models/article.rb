# frozen_string_literal: true

class Article < ActiveRecord::Base
  belongs_to :user
end
