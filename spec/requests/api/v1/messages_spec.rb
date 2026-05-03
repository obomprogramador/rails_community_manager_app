require 'rails_helper'

RSpec.describe 'Api::V1::Messages', type: :request do
  let!(:community) { create(:community) }
  let!(:user)      { create(:user, username: 'john_doe') }

  describe 'POST /api/v1/messages' do
    let(:valid_params) do
      {
        username:          'john_doe',
        community_id:      community.id,
        content:           'Conteúdo da mensagem',
        user_ip:           '192.168.1.1',
        parent_message_id: nil
      }
    end

    context 'quando usuário já existe' do
      it 'retorna o body completo no formato correto' do
        post '/api/v1/messages', params: valid_params

        body = JSON.parse(response.body)

        expect(body).to include(
          'id'                 => be_a(Integer),
          'content'            => 'Conteúdo da mensagem',
          'community_id'       => community.id,
          'parent_message_id'  => nil,
          'sentiment_score' => nil,
          'created_at'         => be_a(String)
        )

        expect(body['user']).to include(
          'id'       => user.id,
          'username' => 'john_doe'
        )
      end

      it 'cria a mensagem e retorna 201' do
        post '/api/v1/messages', params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'retorna o conteúdo correto' do
        post '/api/v1/messages', params: valid_params
        expect(JSON.parse(response.body)['content']).to eq('Conteúdo da mensagem')
      end

      it 'retorna os dados do usuário' do
        post '/api/v1/messages', params: valid_params

        body = JSON.parse(response.body)
        expect(body['user']['username']).to eq('john_doe')
        expect(body['user']['id']).to eq(user.id)
      end

      it 'retorna community_id correto' do
        post '/api/v1/messages', params: valid_params
        expect(JSON.parse(response.body)['community_id']).to eq(community.id)
      end

      it 'retorna parent_message_id nulo quando não informado' do
        post '/api/v1/messages', params: valid_params
        expect(JSON.parse(response.body)['parent_message_id']).to be_nil
      end

      it 'não cria um novo usuário' do
        expect {
          post '/api/v1/messages', params: valid_params
        }.not_to change(User, :count)
      end
    end

    context 'quando usuário não existe' do
      let(:new_user_params) do
        {
          username:          'new_user',
          community_id:      community.id,
          content:           'Primeira mensagem!',
          user_ip:           '192.168.1.1',
          parent_message_id: nil
        }
      end

      it 'cria o usuário e retorna 201' do
        expect {
          post '/api/v1/messages', params: new_user_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it 'retorna os dados do novo usuário criado' do
        post '/api/v1/messages', params: new_user_params
        expect(JSON.parse(response.body)['user']['username']).to eq('new_user')
      end
    end

    context 'quando é um comentário (parent_message_id presente)' do
      let!(:parent_message) { create(:message, community: community, user: user) }

      it 'cria o comentário e retorna 201' do
        post '/api/v1/messages', params: valid_params.merge(
          parent_message_id: parent_message.id
        )

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['parent_message_id']).to eq(parent_message.id)
      end

      it 'levanta erro ao tentar responder uma resposta' do
        reply = create(:message, community: community, user: user, parent_message_id: parent_message.id)

        post '/api/v1/messages', params: valid_params.merge(
          parent_message_id: reply.id
        )

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to match(/responder uma resposta/)
      end

      it 'levanta erro se mensagem pai não existe' do
        post '/api/v1/messages', params: valid_params.merge(
          parent_message_id: 99999
        )

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to match(/não encontrada/)
      end
    end

    context 'quando usuário está inativo' do
      before { user.update!(active: false) }

      it 'retorna 422' do
        post '/api/v1/messages', params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to match(/inativo/)
      end
    end

    context 'quando parâmetros obrigatórios estão ausentes' do
      it 'retorna 400 sem username' do
        post '/api/v1/messages', params: valid_params.except(:username)

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to match(/username/)
      end

      it 'retorna 400 sem community_id' do
        post '/api/v1/messages', params: valid_params.except(:community_id)

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to match(/community_id/)
      end

      it 'retorna 400 sem content' do
        post '/api/v1/messages', params: valid_params.except(:content)

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to match(/content/)
      end
    end

    context 'quando content é inválido' do
      it 'retorna 400 se content vazio' do
        post '/api/v1/messages', params: valid_params.merge(content: '')
        expect(response).to have_http_status(:bad_request)
      end

      it 'retorna 400 se content muito longo' do
        post '/api/v1/messages', params: valid_params.merge(content: 'a' * 5001)
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'quando username é inválido' do
      it 'retorna 400 se username muito curto' do
        post '/api/v1/messages', params: valid_params.merge(username: 'ab')
        expect(response).to have_http_status(:bad_request)
      end

      it 'retorna 400 se username com caracteres inválidos' do
        post '/api/v1/messages', params: valid_params.merge(username: 'john doe!')
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'quando user_ip é inválido' do
      it 'retorna 400 se user_ip tem formato inválido' do
        post '/api/v1/messages', params: valid_params.merge(user_ip: 'ip-invalido')
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'GET /api/v1/messages' do
    before { create_list(:message, 3, community: community, user: user) }

    context 'quando community_id está presente' do
      it 'retorna mensagens com status 200' do
        get '/api/v1/messages', params: { community_id: community.id }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(3)
      end

      it 'retorna apenas mensagens raiz' do
        parent = create(:message, community: community, user: user)
        create(:message, community: community, user: user, parent_message_id: parent.id)

        get '/api/v1/messages', params: { community_id: community.id }

        body = JSON.parse(response.body)
        expect(body.all? { |m| m['parent_message_id'].nil? }).to be true
      end

      it 'respeita o limite de per_page' do
        create_list(:message, 10, community: community, user: user)

        get '/api/v1/messages', params: { community_id: community.id, per_page: 5 }

        expect(JSON.parse(response.body).size).to eq(5)
      end

      it 'retorna mensagens ordenadas da mais recente para a mais antiga' do
        get '/api/v1/messages', params: { community_id: community.id }

        body  = JSON.parse(response.body)
        dates = body.map { |m| Time.parse(m['created_at']) }
        expect(dates).to eq(dates.sort.reverse)
      end

      it 'retorna o body completo no formato correto' do
        get '/api/v1/messages', params: { community_id: community.id }

        body    = JSON.parse(response.body)
        message = body.first

        expect(message).to include(
          'id'                 => be_a(Integer),
          'content'            => be_a(String),
          'community_id'       => community.id,
          'parent_message_id'  => nil,
          'sentiment_score' => nil,
          'created_at'         => be_a(String)
        )

        expect(message['user']).to include(
          'id'       => be_a(Integer),
          'username' => be_a(String)
        )
      end
    end

    context 'quando paginação é inválida' do
      it 'usa page 1 como default se page não informado' do
        get '/api/v1/messages', params: { community_id: community.id }
        expect(response).to have_http_status(:ok)
      end

      it 'usa page 1 se page for negativo' do
        get '/api/v1/messages', params: { community_id: community.id, page: -1 }
        expect(response).to have_http_status(:ok)
      end

      it 'usa page 1 se page for string inválida' do
        get '/api/v1/messages', params: { community_id: community.id, page: 'abc' }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end