require 'rails_helper'

RSpec.describe 'Api::V1::Reactions', type: :request do
  let!(:community) { create(:community) }
  let!(:user)      { create(:user) }
  let!(:message)   { create(:message, community: community, user: user) }

  describe 'POST /api/v1/reactions' do
    let(:valid_params) do
      {
        message_id:    message.id,
        user_id:       user.id,
        reaction_type: 'like'
      }
    end

    context 'quando dados válidos' do
      it 'retorna status 200' do
        post '/api/v1/reactions', params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'retorna o body completo no formato correto' do
        post '/api/v1/reactions', params: valid_params

        body = JSON.parse(response.body)

        expect(body).to include(
          'message_id' => message.id,
          'reactions'  => include(
            'like'       => be_a(Integer),
            'love'       => be_a(Integer),
            'haha'       => be_a(Integer),
            'wow'        => be_a(Integer),
            'sad'        => be_a(Integer),
            'angry'      => be_a(Integer),
            'insightful' => be_a(Integer)
          )
        )
      end

      it 'retorna contagem correta de reações' do
        # cria reações prévias na mensagem
        other_user_1 = create(:user)
        other_user_2 = create(:user)
        other_user_3 = create(:user)

        create(:reaction, message: message, user: other_user_1, reaction_type: 'like')
        create(:reaction, message: message, user: other_user_2, reaction_type: 'like')
        create(:reaction, message: message, user: other_user_3, reaction_type: 'love')

        post '/api/v1/reactions', params: valid_params

        body      = JSON.parse(response.body)
        reactions = body['reactions']

        expect(reactions['like']).to eq(3)       # 2 existentes + 1 nova
        expect(reactions['love']).to eq(1)
        expect(reactions['insightful']).to eq(0)
      end

      it 'retorna todos os tipos mesmo com contagem zero' do
        post '/api/v1/reactions', params: valid_params

        body      = JSON.parse(response.body)
        reactions = body['reactions']

        expect(reactions.keys).to match_array(%w[like love haha wow sad angry insightful])
        expect(reactions['like']).to eq(1)
        expect(reactions['love']).to eq(0)
        expect(reactions['haha']).to eq(0)
        expect(reactions['wow']).to eq(0)
        expect(reactions['sad']).to eq(0)
        expect(reactions['angry']).to eq(0)
        expect(reactions['insightful']).to eq(0)
      end

      it 'cria a reação no banco' do
        expect {
          post '/api/v1/reactions', params: valid_params
        }.to change(Reaction, :count).by(1)
      end

      it 'permite mesmo usuário reagir com tipos diferentes' do
        create(:reaction, message: message, user: user, reaction_type: 'like')

        post '/api/v1/reactions', params: valid_params.merge(reaction_type: 'love')

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['reactions']['love']).to eq(1)
      end

      it 'permite usuários diferentes reagirem com o mesmo tipo' do
        other_user = create(:user)
        create(:reaction, message: message, user: other_user, reaction_type: 'like')

        post '/api/v1/reactions', params: valid_params

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['reactions']['like']).to eq(2)
      end
    end

    context 'quando reação duplicada' do
      before do
        create(:reaction, message: message, user: user, reaction_type: 'like')
      end

      it 'retorna status 409 conflict' do
        post '/api/v1/reactions', params: valid_params
        expect(response).to have_http_status(:conflict)
      end

      it 'retorna mensagem de erro clara' do
        post '/api/v1/reactions', params: valid_params
        expect(JSON.parse(response.body)['error']).to match(/já reagiu/)
      end

      it 'não cria reação duplicada no banco' do
        expect {
          post '/api/v1/reactions', params: valid_params
        }.not_to change(Reaction, :count)
      end
    end

    context 'quando parâmetros obrigatórios estão ausentes' do
      it 'retorna 400 sem message_id' do
        post '/api/v1/reactions', params: valid_params.except(:message_id)

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to match(/message_id/)
      end

      it 'retorna 400 sem user_id' do
        post '/api/v1/reactions', params: valid_params.except(:user_id)

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to match(/user_id/)
      end

      it 'retorna 400 sem reaction_type' do
        post '/api/v1/reactions', params: valid_params.except(:reaction_type)

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to match(/reaction_type/)
      end
    end

    context 'quando reaction_type é inválido' do
      it 'retorna 400' do
        post '/api/v1/reactions', params: valid_params.merge(reaction_type: 'dislike')

        expect(response).to have_http_status(:conflict)
        expect(JSON.parse(response.body)['error']).to match(/inválido/)
      end
    end
  end
end