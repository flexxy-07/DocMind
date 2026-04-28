from fastembed import TextEmbedding
from typing import List

# We load the model ONCE when the server starts.
# Loading takes ~3 seconds the first time.
# After that it lives in memory and each embedding takes ~80ms.
#
# _model starts as None and gets set the first time get_model() is called.
# This pattern is called "lazy loading" — we don't load until we need it.

_model: TextEmbedding | None = None
 
def get_model() -> TextEmbedding:
    """
    Returns the embedding model, loading it if not already loaded.
    All other functions call this — never access _model directly.
    """
    global _model
 
    if _model is None:
        print("Loading embedding model — this takes ~3s on first load...")
 
        # fastembed uses ONNX runtime, saving massive amounts of RAM over PyTorch
        _model = TextEmbedding(model_name="sentence-transformers/all-MiniLM-L6-v2")
 
        print("Embedding model ready [OK]")
 
    return _model
 
def embed_texts(texts: List[str]) -> List[List[float]]:
    """
    Converts a LIST of strings into a list of vectors.
    Use this when embedding chunks during ingestion.
    """
    model = get_model()
    
    # fastembed returns a generator of numpy arrays, we convert it to a list of lists.
    embeddings = list(model.embed(texts, batch_size=32))
    
    return [embedding.tolist() for embedding in embeddings]
 
def embed_query(text: str) -> List[float]:
    """
    Converts a SINGLE string into a vector.
    """
    return embed_texts([text])[0]