puts "🔥 CAPYBARA CONFIG CARREGADA"
require 'rails_helper'

RSpec.feature "Session", type: :feature do
  let!(:user) { create(:user, :with_username) }

  scenario "usuário faz login com sucesso", js: true do
    current_user = user

    # Dado (Given)
    visit new_session_path
    
    # Então (Then) - Verificações iniciais
    expect(page).to have_content("Community Manager")
    expect(page).to have_content("Faça login para continuar")
    expect(page).to have_field("Nome de usuário")
    expect(page).to have_button("Entrar")

    # Quando (When) - Ação do usuário
    fill_in "Nome de usuário", with: current_user.username
    
    click_button "Entrar"

    # Então (Then) - Resultado esperado
    # O Rails redireciona para o feed ou home após login
    expect(page).to have_current_path(feed_path) 
    expect(page).to have_content("Olá, #{current_user.username}") # Verifica se a sessão foi criada
  end

  scenario "usuário tenta login com credenciais inválidas", js: true do
    current_user = user

    # Dado (Given)
    visit new_session_path

    # Então (Then) - Preenche nome de usuário inexistente
    fill_in "Nome de usuário", with: "#{current_user.username}_inexistente"
    
    click_button "Entrar"

    # Espera o elemento aparecer (Stimulus pode ter delay)
    expect(page).to have_selector('.flash.flash--alert', visible: true, wait: 5)
    
    # Verifica o conteúdo da mensagem de erro
    expect(page).to have_content('Usuário não encontrado')
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