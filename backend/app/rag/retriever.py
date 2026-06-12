from app.rag.embedder import model
from app.rag.vector_store import search_vector_store

def retrieve_relevant_chunks(query):

    query_embedding = model.encode([query])[0]

    results = search_vector_store(query_embedding)

    return results