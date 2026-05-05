class BackfillEngagementCountersOnMessages < ActiveRecord::Migration[7.2]
  # Desabilita o timeout padrão de migrations para operações longas
  disable_ddl_transaction!

  def up
    # SQL direto — muito mais eficiente que reset_counters por registro
    # Atualiza reactions_count e replies_count em uma única passagem por batch
    execute <<~SQL
      UPDATE messages m
      SET
        reactions_count = (
          SELECT COUNT(*) FROM reactions WHERE message_id = m.id
        ),
        replies_count = (
          SELECT COUNT(*) FROM messages r WHERE r.parent_message_id = m.id
        )
    SQL

    # Se a tabela for muito grande (ex: milhões de registros),
    # substitua o UPDATE acima por batches com um loop em Ruby:
    #
    # Message.in_batches(of: 1000) do |batch|
    #   batch.update_all("
    #     reactions_count = (SELECT COUNT(*) FROM reactions WHERE message_id = messages.id),
    #     replies_count   = (SELECT COUNT(*) FROM messages r WHERE r.parent_message_id = messages.id)
    #   ")
    #   sleep(0.05)
    # end
  end

  def down
    # Zera os contadores — o down da migration 1 remove as colunas de qualquer forma
    execute "UPDATE messages SET reactions_count = 0, replies_count = 0"
  end
end