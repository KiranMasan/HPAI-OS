from app.rag.pdf_parser import extract_text_from_pdf
from app.rag.chunker import chunk_text
from app.rag.embedder import create_embeddings
from app.rag.vector_store import create_vector_store

from app.rag.retriever import retrieve_relevant_chunks

from app.services.ollama_service import generate_response

def process_pdf(pdf_path):

    text = extract_text_from_pdf(pdf_path)

    chunks = chunk_text(text)

    embeddings = create_embeddings(chunks)

    create_vector_store(embeddings, chunks)

def ask_pdf(question):

    relevant_chunks = retrieve_relevant_chunks(question)

    if not relevant_chunks or len(relevant_chunks) == 0:
        return "No relevant information found in the uploaded document."

    context = "\n".join(relevant_chunks)

    prompt = f"""
    Answer ONLY from the provided context.

    Context:
    {context}

    Question:
    {question}

    If answer is not in context,
    say:
    "Answer not found in uploaded document."
    """

    response = generate_response(prompt)

    if not response or response.strip() == "":
        return "Could not generate response. Please try again."

    return response