import faiss
import numpy as np

index = None
stored_chunks = []

def create_vector_store(embeddings, chunks):

    global index
    global stored_chunks

    dimension = len(embeddings[0])

    index = faiss.IndexFlatL2(dimension)

    index.add(np.array(embeddings).astype('float32'))

    stored_chunks = chunks

def search_vector_store(query_embedding, top_k=3):

    global index
    global stored_chunks

    distances, indices = index.search(
        np.array([query_embedding]).astype('float32'),
        top_k
    )

    results = []

    for idx in indices[0]:
        results.append(stored_chunks[idx])

    return results