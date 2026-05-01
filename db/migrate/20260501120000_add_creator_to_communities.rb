# frozen_string_literal: true

class AddCreatorToCommunities < ActiveRecord::Migration[7.2]
  def change
    add_reference :communities, :creator, null: false, foreign_key: { to_table: :users }
  end
end
