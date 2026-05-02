# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'faker'

puts "🧹 Limpando banco de dados..."
Reaction.delete_all
Message.delete_all
CommunityMember.delete_all
Community.delete_all
User.delete_all

# ============================================================
# CONFIGURAÇÕES
# ============================================================
TOTAL_USERS       = 50
TOTAL_COMMUNITIES = 4
TOTAL_MESSAGES    = 1000
ROOT_PERCENTAGE   = 0.70
REPLY_PERCENTAGE  = 0.30
REACTION_CHANCE   = 0.80
UNIQUE_IPS        = 20
REACTION_TYPES    = %w[like love insightful].freeze
ROLES             = %w[member member member moderator].freeze # maioria member

# ============================================================
# USUÁRIOS
# ============================================================
puts "👤 Criando #{TOTAL_USERS} usuários..."

users = TOTAL_USERS.times.map do |i|
  User.create!(
    username: "#{Faker::Internet.unique.username(specifier: 5..15, separators: ['_'])}_#{i}",
    active:   true
  )
end

puts "   ✅ #{users.size} usuários criados"

# ============================================================
# IPs ÚNICOS
# ============================================================
puts "🌐 Gerando #{UNIQUE_IPS} IPs únicos..."

unique_ips = UNIQUE_IPS.times.map { Faker::Internet.unique.ip_v4_address }

puts "   ✅ #{unique_ips.size} IPs gerados"

# ============================================================
# COMUNIDADES
# ============================================================
puts "🏘️  Criando #{TOTAL_COMMUNITIES} comunidades..."

community_data = [
  { name: 'Ruby on Rails Brasil',    description: 'Comunidade brasileira de Ruby on Rails' },
  { name: 'Clean Architecture',      description: 'Discussões sobre arquitetura limpa e boas práticas' },
  { name: 'DevOps & Infraestrutura', description: 'Docker, Kubernetes, CI/CD e tudo mais' },
  { name: 'Carreira em Tech',        description: 'Dicas, vagas e experiências na área de tecnologia' }
]

communities = community_data.map do |data|
  creator = users.sample
  community = Community.create!(
    name:        data[:name],
    description: data[:description],
    creator_id:  creator.id
  )

  # Creator entra como admin automaticamente
  CommunityMember.create!(
    community: community,
    user:      creator,
    role:      'admin'
  )

  community
end

puts "   ✅ #{communities.size} comunidades criadas"

# ============================================================
# MEMBROS DAS COMUNIDADES
# ============================================================
puts "👥 Adicionando membros às comunidades..."

member_count = 0

communities.each do |community|
  # Entre 20 e 40 membros por comunidade
  members_sample = (users - [User.find(community.creator_id)]).sample(rand(20..40))

  members_sample.each do |user|
    next if CommunityMember.exists?(community: community, user: user)

    CommunityMember.create!(
      community: community,
      user:      user,
      role:      ROLES.sample
    )
    member_count += 1
  end
end

puts "   ✅ #{member_count} membros adicionados"

# ============================================================
# MENSAGENS RAIZ (70%)
# ============================================================
puts "💬 Criando mensagens raiz (#{(ROOT_PERCENTAGE * 100).to_i}%)..."

root_total    = (TOTAL_MESSAGES * ROOT_PERCENTAGE).to_i
root_messages = []

root_total.times do
  community = communities.sample
  user      = users.sample

  message = Message.create!(
    user:      user,
    community: community,
    content:   Faker::Lorem.paragraph(sentence_count: rand(1..5)),
    user_ip:   unique_ips.sample
  )

  root_messages << message
end

puts "   ✅ #{root_messages.size} mensagens raiz criadas"

# ============================================================
# RESPOSTAS (30%)
# ============================================================
puts "↩️  Criando respostas (#{(REPLY_PERCENTAGE * 100).to_i}%)..."

reply_total = (TOTAL_MESSAGES * REPLY_PERCENTAGE).to_i
replies     = []

reply_total.times do
  parent    = root_messages.sample
  user      = users.sample

  reply = Message.create!(
    user:              user,
    community:         parent.community,
    parent_message_id: parent.id,
    content:           Faker::Lorem.paragraph(sentence_count: rand(1..3)),
    user_ip:           unique_ips.sample
  )

  replies << reply
end

puts "   ✅ #{replies.size} respostas criadas"

# ============================================================
# REAÇÕES (80% das mensagens)
# ============================================================
puts "😀 Criando reações (#{(REACTION_CHANCE * 100).to_i}% das mensagens)..."

all_messages  = root_messages + replies
reaction_count = 0

all_messages.each do |message|
  next unless rand < REACTION_CHANCE

  # Entre 1 e 5 reações por mensagem de usuários diferentes
  reactors = users.sample(rand(1..5))

  reactors.each do |user|
    reaction_type = REACTION_TYPES.sample

    next if Reaction.exists?(
      message:       message,
      user:          user,
      reaction_type: reaction_type
    )

    Reaction.create!(
      message:       message,
      user:          user,
      reaction_type: reaction_type
    )
    reaction_count += 1
  end
end

puts "   ✅ #{reaction_count} reações criadas"

# ============================================================
# RESUMO FINAL
# ============================================================
puts ""
puts "🎉 Seed concluído com sucesso!"
puts "=================================="
puts "👤 Usuários:     #{User.count}"
puts "🏘️  Comunidades:  #{Community.count}"
puts "👥 Membros:      #{CommunityMember.count}"
puts "💬 Mensagens:    #{Message.count}"
puts "   ↳ Raiz:       #{Message.where(parent_message_id: nil).count}"
puts "   ↳ Respostas:  #{Message.where.not(parent_message_id: nil).count}"
puts "😀 Reações:      #{Reaction.count}"
puts "   ↳ like:       #{Reaction.where(reaction_type: 'like').count}"
puts "   ↳ love:       #{Reaction.where(reaction_type: 'love').count}"
puts "   ↳ insightful: #{Reaction.where(reaction_type: 'insightful').count}"
puts "=================================="