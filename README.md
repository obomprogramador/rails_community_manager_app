<div align="center">

# 🏘️ Rails Community Manager

**Mini rede social para gestão de comunidades, construída com Clean Architecture**

<img width="1920" height="1008" alt="Captura de tela de 2026-05-05 17-22-29" src="https://github.com/user-attachments/assets/845d0b90-0f2f-497e-bdb1-977baf7817ca" />
<img width="1920" height="1008" alt="Captura de tela de 2026-05-05 17-23-21" src="https://github.com/user-attachments/assets/6a363991-ef75-4583-bd2e-0ea20e0c23b0" />
<img width="1920" height="1008" alt="Captura de tela de 2026-05-05 17-22-56" src="https://github.com/user-attachments/assets/4d44fb43-b5ea-4cc7-99fa-582224e7aecf" />
<img width="1920" height="1008" alt="Captura de tela de 2026-05-05 17-22-44" src="https://github.com/user-attachments/assets/b312e53f-006a-4418-a131-c228a4f9a233" />
<img width="1920" height="1008" alt="Captura de tela de 2026-05-05 17-22-38" src="https://github.com/user-attachments/assets/0d521030-ae6b-4764-9e85-874d55ed642e" />

Usuários gerados pelo seed:

<img width="1630" height="777" alt="Captura de tela de 2026-05-05 18-38-22" src="https://github.com/user-attachments/assets/ef288233-5a7a-4cf4-9089-711bd601216d" />


🌐 **[Ver App em Produção](https://rails-community-manager-app.onrender.com/)**
🌐 **[Github do Projeto](https://github.com/obomprogramador/rails_community_manager_app)**

</div>

---

## 📖 Visão Geral

Este projeto é uma **mini rede social de gestão de comunidades**, desenvolvido com dois desafios pessoais autoatribuídos:

1. **Clean Architecture (Uncle Bob)** — desacoplamento total entre regras de negócio e o framework Rails.
2. **Stack SSR com Rails** — uso de HAML + Stimulus + Turbo/Hotwire + ActionCable, saindo da zona de conforto do ReactJS para explorar as novidades do Rails 7+.

> 💡 *Conclusão pessoal: abordagens SSR funcionam bem para MVPs, mas para projetos maiores, libs dedicadas como ReactJS (browser), React Native (mobile) e Electron (desktop) continuam sendo a escolha mais robusta.*

---

## 🚀 Setup do Projeto

### Subir com Docker

```bash
docker compose up -d
```

### Se o container `web` apresentar problemas

```bash
docker compose down -v
docker rmi rails_community_manager_app_web 2>/dev/null || true
docker compose build --no-cache web
docker compose up -d
docker compose exec web bash
```

### Deploy

O projeto foi hospedado no **[Render Web App Builder](https://dashboard.render.com)** — plataforma que oferece 15 dias de app gratuito sem necessidade de cartão de crédito. A experiência de deploy foi significativamente mais simples que alternativas como Fly.io.

---

## 🏛️ Arquitetura

### Clean Architecture

O Rails 7+ possui suporte nativo a estruturas semelhantes à Clean Architecture. Neste projeto, **as regras de negócio são completamente independentes do framework** — funcionam em Ruby puro.

```
clean_arch/
└── domains/
    ├── user_domain/
    │   ├── dtos/
    │   ├── entities/
    │   ├── repositories/
    │   ├── use_cases/
    │   └── value_objects/
    ├── community_domain/
    ├── message_domain/
    └── reaction_domain/
```

### Fluxo de uma Requisição

```
Controller
    │
    ├── InputDto          ← valida e carrega dados da requisição
    │       │
    │       ▼
    │   UseCase           ← regras de negócio (não conhece Rails)
    │       │
    │       ├── ValueObject   ← valida valores do domínio
    │       │
    │       └── Repository    ← ponte com o banco
    │               │
    │               ├── ActiveRecord  ← persiste
    │               └── Entity        ← domínio puro
    │
    └── OutputDto         ← retorna dados para o cliente
```

---

## 🗄️ Banco de Dados

### Diagrama MER

```
User ─────────────────── CommunityMember ─── Community
  │                                               │
  └── Message (user_id) ──────────── (community_id)
        │
        └── Message (parent_message_id) ← auto-referência
        └── Reaction (message_id)
              └── User (user_id)
```

### Estratégia de Banco de Dados

- **Read Replicas (PostgreSQL):** estratégia de leitura/escrita separadas — um banco fonte da verdade para inserção e réplicas para leitura, implementando um mini-CQRS no Rails.
  - 📚 [Rails Multiple Databases](https://guides.rubyonrails.org/active_record_multiple_databases.html)
  - 📚 [AWS RDS Read Replicas](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html)

- **PgBouncer:** connection pooling entre Rails e PostgreSQL — funciona como um "nginx" entre o framework e o banco de dados.

- **Sharding / Cassandra:** conhecidos e avaliados, mas descartados para evitar over-engineering neste projeto.

---

## ⚙️ Use Cases

### 👤 Usuário
| Use Case | Descrição |
|---|---|
| `RegisterUser` | Cadastrar novo usuário |
| `AuthenticateUser` | Login |
| `DeactivateUser` | Desativar conta |

### 🏘️ Comunidade
| Use Case | Descrição |
|---|---|
| `CreateCommunity` | Criar nova comunidade |
| `UpdateCommunity` | Editar nome/descrição |
| `ListCommunities` | Listar todas as comunidades |
| `SearchCommunities` | Buscar comunidades por nome |

### 👥 Membros
| Use Case | Descrição |
|---|---|
| `JoinCommunity` | Usuário entrar em uma comunidade |
| `LeaveCommunity` | Usuário sair de uma comunidade |
| `PromoteMember` | Promover membro a moderador/admin |
| `DemoteMember` | Rebaixar papel do membro |
| `ListCommunityMembers` | Listar membros de uma comunidade |
| `BanMember` | Banir usuário de uma comunidade |

### 💬 Mensagens
| Use Case | Descrição |
|---|---|
| `PostMessage` | Postar mensagem em uma comunidade |
| `ReplyToMessage` | Responder uma mensagem (`parent_message_id`) |
| `ListCommunityMessages` | Listar mensagens de uma comunidade |
| `ListMessageReplies` | Listar respostas de uma mensagem |
| `DeleteMessage` | Remover mensagem |
| `AnalyzeMessageSentiment` | Chamar IA e atualizar `ai_sentiment_score` |

### 😀 Reações
| Use Case | Descrição |
|---|---|
| `AddReaction` | Reagir a uma mensagem |
| `RemoveReaction` | Remover reação |
| `ListMessageReactions` | Listar reações de uma mensagem |

### 🤖 Moderação (IA)
| Use Case | Descrição |
|---|---|
| `FlagMessage` | Sinalizar mensagem como inapropriada |
| `ReviewFlaggedMessages` | Moderador revisar mensagens sinalizadas |
| `AutoModerateMessage` | Bloquear automaticamente mensagens com score muito negativo |

### 📊 Analytics
| Use Case | Descrição |
|---|---|
| `GetCommunitySentimentReport` | Relatório do clima de uma comunidade |
| `GetUserActivityReport` | Relatório de atividade de um usuário |

---

## 🤖 Bot de Análise de Sentimento

O projeto inclui um script Python que representa como um bot de análise de sentimento seria implementado:

```
python_bot_sentiment/bot.py
```

A ideia é rodar este bot em um **cluster Kubernetes** de forma contínua, analisando mensagens e atualizando o `ai_sentiment_score` no banco de dados em tempo real.

---

## 🛠️ Stack Tecnológica

| Camada | Tecnologia |
|---|---|
| Backend | Ruby on Rails 7+ |
| Frontend | HAML + Stimulus + Turbo/Hotwire |
| Real-time | ActionCable |
| Banco de Dados | PostgreSQL |
| Containerização | Docker |
| Bot / IA | Python |
| Deploy | Render |

---

## 📝 Observações Finais

Este projeto foi desenvolvido **sem ferramentas de IA automáticas** como CursorAI (por limitações de cartão de crédito), fazendo uso intenso de mecanismos de busca e planos gratuitos de IA para consulta de documentações e resolução de erros.
