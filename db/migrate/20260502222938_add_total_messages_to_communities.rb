class AddTotalMessagesToCommunities < ActiveRecord::Migration[7.2]
  def change
    add_column :communities, :total_messages, :integer, default: 0, null: false
  end
end
