# frozen_string_literal: true

require 'rails'
require 'shreddies/as_json'

module Shreddies
  class Engine < ::Rails::Engine
    isolate_namespace Shreddies

    initializer 'active_record.enhance_as_json' do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.include Shreddies::AsJson::ActiveRecordBase
        ActiveRecord::Relation.include Shreddies::AsJson::ActiveRecordRelation
      end
    end
  end
end
