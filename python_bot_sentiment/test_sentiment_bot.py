import pytest
import os
import tempfile
import shutil
from unittest.mock import patch, MagicMock
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker

# Importe as funções do seu script principal
# Assumindo que o nome do arquivo é bot_sentimento.py
from bot_sentimento import (
    fetch_unprocessed_messages, 
    update_sentiment_score, 
    init_chroma, 
    store_in_chroma,
    SentimentResult,
    DATABASE_URL
)

# --- Configuração do Banco de Dados de Teste (SQLite em Memória) ---
# Usando SQLite para testes rápidos. Se precisar testar especificamente com Postgres,
# use Docker Compose para subir um container temporário.
TEST_DB_URL = "sqlite:///:memory:"

@pytest.fixture(scope="function")
def db_session():
    """Cria um banco de dados SQLite temporário e retorna a sessão."""
    engine = create_engine(TEST_DB_URL, echo=False)
    
    # Criar as tabelas manualmente (já que não temos o modelo ORM completo no script)
    with engine.connect() as conn:
        conn.execute(text("""
            CREATE TABLE messages (
                id INTEGER PRIMARY KEY,
                content TEXT NOT NULL,
                ai_sentiment_score FLOAT
            );
        """))
        conn.commit()
    
    SessionLocal = sessionmaker(bind=engine)
    session = SessionLocal()
    yield session
    session.close()
    engine.dispose()

@pytest.fixture(scope="function")
def chroma_temp_dir():
    """Cria um diretório temporário para o ChromaDB."""
    temp_dir = tempfile.mkdtemp()
    yield temp_dir
    shutil.rmtree(temp_dir)

# --- Testes ---

def test_fetch_empty_messages(db_session):
    """Testa quando não há mensagens pendentes."""
    messages = fetch_unprocessed_messages(db_session, limit=10)
    assert len(messages) == 0

def test_fetch_pending_messages(db_session):
    """Testa a busca de mensagens com score NULL."""
    # Inserir dados de teste
    db_session.execute(text("INSERT INTO messages (content, ai_sentiment_score) VALUES ('Ótimo dia!', NULL)"))
    db_session.execute(text("INSERT INTO messages (content, ai_sentiment_score) VALUES ('Dia ruim.', 0.5)")) # Já processada
    db_session.execute(text("INSERT INTO messages (content, ai_sentiment_score) VALUES ('Adorei tudo.', NULL)"))
    db_session.commit()

    messages = fetch_unprocessed_messages(db_session, limit=10)
    
    assert len(messages) == 2
    assert messages[0]['content'] == 'Ótimo dia!'
    assert messages[1]['content'] == 'Adorei tudo.'

def test_update_sentiment_score(db_session):
    """Testa a atualização do score no banco."""
    db_session.execute(text("INSERT INTO messages (content, ai_sentiment_score) VALUES ('Teste', NULL)"))
    db_session.commit()
    
    # Pega o ID inserido (em SQLite em memória, o último ID é fácil de pegar ou usamos um ID fixo)
    # Vamos inserir com ID conhecido para facilitar
    db_session.execute(text("DELETE FROM messages"))
    db_session.execute(text("INSERT INTO messages (id, content, ai_sentiment_score) VALUES (999, 'Teste', NULL)"))
    db_session.commit()

    update_sentiment_score(db_session, 999, 0.85)
    
    result = db_session.execute(text("SELECT ai_sentiment_score FROM messages WHERE id = 999")).fetchone()
    assert result[0] == 0.85

def test_chroma_storage(chroma_temp_dir):
    """Testa se o ChromaDB salva os dados corretamente."""
    # Mockar o path do ChromaDB para usar o diretório temporário
    with patch('bot_sentimento.CHROMA_PERSIST_DIR', chroma_temp_dir):
        collection = init_chroma()
        
        store_in_chroma(collection, "msg_123", "Texto de teste positivo", 0.9)
        
        # Verificar se o documento existe
        results = collection.get(ids=["msg_123"])
        assert len(results['ids']) == 1
        assert results['documents'][0] == "Texto de teste positivo"
        assert results['metadatas'][0]['score'] == 0.9

def test_full_flow_with_mocked_llm(db_session, chroma_temp_dir):
    """
    Testa o fluxo completo:
    1. Insere mensagem no DB.
    2. Mocka a chamada ao LLM para retornar score fixo.
    3. Executa a lógica de processamento (simulada aqui).
    4. Verifica se o DB e ChromaDB foram atualizados.
    """
    # 1. Setup DB
    db_session.execute(text("INSERT INTO messages (id, content, ai_sentiment_score) VALUES (100, 'Isso é incrível!', NULL)"))
    db_session.commit()

    # 2. Mockar o LLM
    mock_result = SentimentResult(score=0.95, reason="Uso de palavra positiva 'incrível'")
    
    # Mockar a função get_llm para retornar um chain que sempre devolve o mock_result
    def mock_invoke(input_data):
        return mock_result

    with patch('bot_sentimento.get_llm') as mock_get_llm, \
         patch('bot_sentimento.CHROMA_PERSIST_DIR', chroma_temp_dir):
        
        # Configurar o mock
        mock_chain_instance = MagicMock()
        mock_chain_instance.invoke = mock_invoke
        mock_get_llm.return_value = mock_chain_instance
        
        # Re-inicializar o Chroma dentro do contexto do mock
        chroma_collection = init_chroma()

        # Simular o loop de processamento (parte crítica do script)
        messages = fetch_unprocessed_messages(db_session, limit=10)
        
        assert len(messages) == 1
        
        msg = messages[0]
        
        # Chamar o LLM mockado
        result = mock_chain_instance.invoke({"text": msg['content']})
        
        # Atualizar DB
        update_sentiment_score(db_session, msg['id'], result.score)
        
        # Salvar no Chroma
        store_in_chroma(chroma_collection, str(msg['id']), msg['content'], result.score)

        # 3. Validações
        # Verificar DB
        db_check = db_session.execute(text("SELECT ai_sentiment_score FROM messages WHERE id = 100")).fetchone()
        assert db_check[0] == 0.95
        
        # Verificar Chroma
        chroma_check = chroma_collection.get(ids=["100"])
        assert chroma_check['metadatas'][0]['score'] == 0.95

if __name__ == "__main__":
    pytest.main([__file__, "-v"])