# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.text :type
    t.text :first_name
    t.text :last_name
    t.text :email
  end

  create_table :posts do |t|
    t.text :title
  end
end
