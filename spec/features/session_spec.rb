puts "🔥 CAPYBARA CONFIG CARREGADA"
require 'rails_helper'

RSpec.feature "Session", type: :feature do
  let(:user) { create(:user, :with_username) }

  scenario "usuário faz login com sucesso", js: true do
    # Dado (Given)
    visit new_session_path
    
    # Então (Then) - Verificações iniciais
    expect(page).to have_content("Community Manager")
    expect(page).to have_content("Faça login para continuar")
    expect(page).to have_field("Nome de usuário")
    expect(page).to have_button("Entrar")

    sleep 5

    # Quando (When) - Ação do usuário
    fill_in "Nome de usuário", with: "john_doe"

    binding.pry
    
    click_button "Entrar"

    # Então (Then) - Resultado esperado
    # O Rails redireciona para o feed ou home após login
    expect(page).to have_current_path(feed_path) 
    expect(page).to have_content("Olá, john_doe") # Verifica se a sessão foi criada
  end

  scenario "usuário tenta login com credenciais inválidas", js: true do
    # Dado (Given)
    visit new_session_path

    # Então (Then) - Preenche nome de usuário inesistente
    fill_in "Nome de usuário", with: "usuario_inexistente"
    
    click_button "Entrar"

    # Verifica se a mensagem de erro apareceu (interação com Stimulus)
    # O Stimulus deve tornar visível o elemento com data-target="error"
    expect(page).to have_selector(".form-error", visible: true)
    expect(page).to have_content("Credenciais inválidas") # Ou a mensagem que seu backend retorna
  end

  scenario "usuário navega para a página de cadastro", js: true do
    # Dado (Given)
    visit new_session_path
    
    # Quando (When) - Ação do usuário
    click_link "Cadastre-se"
    
    # Então (Then) - Resultado esperado
    # Página de cadastro renderizada corretamente
    expect(page).to have_current_path(new_user_path)
  end
end