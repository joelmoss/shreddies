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

  create_table :articles do |t|
    t.text :title
    t.text :subtitle
  end
end
