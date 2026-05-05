namespace :backfill do
  desc "Preenche reactions_count e replies_count nas mensagens existentes"
  task engagement_counters: :environment do
    total    = Message.count
    atual    = 0
    falhas   = 0

    puts "Iniciando backfill de #{total} mensagens..."
    puts "----------------------------------------"

    Message.in_batches(of: 1000) do |batch|
      begin
        batch.update_all("
          reactions_count = (SELECT COUNT(*) FROM reactions WHERE message_id = messages.id),
          replies_count   = (SELECT COUNT(*) FROM messages r WHERE r.parent_message_id = messages.id)
        ")

        atual += batch.count
        progresso = ((atual.to_f / total) * 100).round(1)
        puts "#{atual}/#{total} (#{progresso}%) processados..."

        sleep(0.05) # throttle para não sobrecarregar o banco
      rescue => e
        falhas += 1
        puts "ERRO no batch: #{e.message}"
        next # continua para o próximo batch mesmo com erro
      end
    end

    puts "----------------------------------------"
    puts "Backfill concluído! #{atual} mensagens processadas. Falhas: #{falhas}"
  end
end