class AddEngagementCountersToMessages < ActiveRecord::Migration[7.2]
  def up
    add_column :messages, :reactions_count, :integer, default: 0, null: false
    add_column :messages, :replies_count, :integer, default: 0, null: false

    add_column :messages, :engagement_score, :virtual,
      type: :float,
      as: "(reactions_count * 1.5) + (replies_count * 1.0)",
      stored: true

    add_index :messages,
      [:community_id, :parent_message_id, :engagement_score],
      order: { engagement_score: :desc },
      name: 'idx_messages_on_comm_parent_score'
  end

  def down
    remove_index :messages, name: 'idx_messages_on_comm_parent_score'
    remove_column :messages, :engagement_score
    remove_column :messages, :replies_count
    remove_column :messages, :reactions_count
  end
end