import os
import sys
from typing import List, Optional
from dotenv import load_dotenv
from sqlalchemy import create_engine, select, update
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.exc import SQLAlchemyError

# LangChain Imports
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.pydantic_v1 import BaseModel, Field

# ChromaDB Imports
import chromadb
from chromadb.config import Settings

# Carregar variáveis de ambiente
load_dotenv()

# --- Configurações ---
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:password@localhost:5432/your_db_name")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "sk-your-key")
OPENAI_BASE_URL = os.getenv("OPENAI_BASE_URL", "https://api.openai.com/v1") # Pode ser uma URL customizada (ex: Azure, Ollama proxy)
CHROMA_PERSIST_DIR = "./chroma_db_sentiment"

# --- Definição do Modelo de Saída do LLM ---
class SentimentResult(BaseModel):
    """Estrutura esperada da resposta do LLM"""
    score: float = Field(..., description="Score de sentimento entre -1.0 (muito negativo) e 1.0 (muito positivo)")
    reason: str = Field(..., description="Breve explicação do motivo do score")

# --- Configuração do LLM (LangChain + OpenAI) ---
def get_llm():
    llm = ChatOpenAI(
        model="gpt-4o-mini", # Ou outro modelo disponível na sua URL
        api_key=OPENAI_API_KEY,
        base_url=OPENAI_BASE_URL,
        temperature=0.0
    )
    
    prompt = ChatPromptTemplate.from_messages([
        ("system", "Você é um analista de sentimentos especializado em comunidades online. Analise o texto fornecido."),
        ("human", "Texto: '{text}'\n\nRetorne APENAS um JSON válido com os campos 'score' (float entre -1 e 1) e 'reason' (string curta). Não adicione markdown ou texto extra.")
    ])
    
    chain = prompt | llm.with_structured_output(SentimentResult)
    return chain

# --- Configuração do Banco de Dados ---
engine = create_engine(DATABASE_URL, echo=False)
SessionLocal = sessionmaker(bind=engine)

def fetch_unprocessed_messages(session: Session, limit: int = 100) -> List[dict]:
    """
    Busca mensagens que precisam de análise.
    Assumindo que queremos analisar mensagens onde ai_sentiment_score é NULL.
    """
    # Nota: Ajuste a query conforme necessário. Aqui estou simulando a estrutura do seu schema.
    # Como não temos o modelo ORM definido, usamos raw SQL ou tabelas genéricas.
    # Para simplicidade, vou usar uma query direta com SQLAlchemy Core.
    
    from sqlalchemy import table, column, Integer, String, Float, DateTime
    
    messages_table = table('messages', 
                           column('id', Integer),
                           column('content', String),
                           column('ai_sentiment_score', Float))
    
    stmt = select(messages_table.c.id, messages_table.c.content).where(
        messages_table.c.ai_sentiment_score.is_(None)
    ).limit(limit)
    
    results = session.execute(stmt).fetchall()
    return [{"id": row.id, "content": row.content} for row in results]

def update_sentiment_score(session: Session, message_id: int, score: float):
    """Atualiza o score no banco"""
    messages_table = table('messages', column('id', Integer), column('ai_sentiment_score', Float))
    stmt = update(messages_table).where(messages_table.c.id == message_id).values(ai_sentiment_score=score)
    session.execute(stmt)
    session.commit()

# --- Configuração do ChromaDB ---
def init_chroma():
    client = chromadb.PersistentClient(path=CHROMA_PERSIST_DIR)
    collection = client.get_or_create_collection(name="sentiment_analysis")
    return collection

def store_in_chroma(collection, message_id: str, text: str, score: float):
    """Armazena embedding e metadata no ChromaDB"""
    # O ChromaDB gera embeddings automaticamente se não passarmos um embedding function explícito
    # Ele usa o padrão (SentenceTransformer) se não configurado, ou pode usar OpenAI se passar o cliente
    collection.add(
        ids=[str(message_id)],
        documents=[text],
        metadatas=[{"score": score}]
    )

# --- Função Principal ---
def run_sentiment_bot():
    print("🚀 Iniciando Bot de Análise de Sentimento...")
    
    # 1. Inicializar componentes
    try:
        llm_chain = get_llm()
        chroma_collection = init_chroma()
        print("✅ Componentes inicializados (LLM e ChromaDB).")
    except Exception as e:
        print(f"❌ Erro ao inicializar: {e}")
        return

    # 2. Conectar ao DB e Processar
    with SessionLocal() as session:
        messages = fetch_unprocessed_messages(session, limit=50) # Limite de 50 por execução
        
        if not messages:
            print("ℹ️ Nenhuma mensagem pendente para análise.")
            return

        print(f"📊 Encontradas {len(messages)} mensagens para analisar.")

        for msg in messages:
            try:
                print(f"⏳ Analisando mensagem ID: {msg['id']}...")
                
                # Chamar LLM
                result = llm_chain.invoke({"text": msg['content']})
                score = result.score
                
                # Atualizar DB
                update_sentiment_score(session, msg['id'], score)
                
                # Salvar no ChromaDB
                store_in_chroma(chroma_collection, msg['id'], msg['content'], score)
                
                print(f"✅ Mensagem {msg['id']} processada. Score: {score}")
                
            except Exception as e:
                print(f"❌ Erro ao processar mensagem {msg['id']}: {e}")
                continue

    print("🏁 Processamento concluído.")

if __name__ == "__main__":
    # Verifica se as variáveis estão definidas
    if not DATABASE_URL or not OPENAI_API_KEY:
        print("Erro: Variáveis de ambiente DATABASE_URL e OPENAI_API_KEY não definidas.")
        sys.exit(1)
        
    run_sentiment_bot()