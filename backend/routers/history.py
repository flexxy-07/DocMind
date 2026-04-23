from fastapi import APIRouter, HTTPException
from typing import Optional, List
from models.schemas import DocRecord, SessionRecord
from services.firebase_store import (
    get_doc_record,
    list_doc_records,
    delete_doc_record,
    get_session,
    list_sessions,
    save_session,
    delete_sessions_for_doc,
    delete_file,
)
from services.vector_store import delete_doc_chunks

router = APIRouter(prefix='/history', tags=['history'])

# docs
@router.get('/docs', response_model=List[DocRecord])
def list_document():
  """
  list of uploaded docs
  """
  
  records = list_doc_records()
  return [DocRecord(**r) for r in records]

@router.get('/docs/{doc_id}', response_model=DocRecord)
def get_document(doc_id: str):
  """
  get one doc record by id
  """
  
  record = get_doc_record(doc_id)
  if not record:
    raise HTTPException(status_code=404, detail=f"Document '{doc_id}' not found")
  
  return DocRecord(**record)


@router.delete("/docs/{doc_id}")
def delete_document(doc_id: str):
  """
  Deletes a document and all its associated data from eveywhere
  
  Order matters : we delete vectors and file first
  """
  
  record = get_doc_record(doc_id)
  if not record:
    raise HTTPException(status_code=404, detail=f"Document '{doc_id}' not found")
  
  
  filename = record.get('filename', "")
  
  # fron qdrant first
  try:
    delete_doc_chunks(doc_id)
  except Exception as e:
    raise HTTPException(
      status_code=500,
      detail=f"Failed to delete vectors from Qdrant: {str(e)}"
    )
    
  # del from cloudinary
  try:
    delete_file(doc_id=doc_id, filename=filename)
  except Exception as e:
    print(f"Warning: Could not delete Cloudinary file for {doc_id}: {e}")
    
  # from fireStore
  delete_doc_record(doc_id)
  
  # delete chat sessions for this doc
  delete_sessions_for_doc(doc_id)
  
  return {
    'message' : f"Document '{filename}' deleted successfully.",
    'doc_id' : doc_id
  }  
  
  
# Session -> One full convo- all the messages b/w user and AI

@router.get('/sessions')
def list_all_sessions(doc_id: Optional[str] = None):
  """
    Lists chat sessions.
 
    Optional query parameter: ?doc_id=abc-123
    If provided → returns only sessions for that document
    If omitted  → returns all sessions
 
    Flutter uses this to show chat history per document
    on the document detail screen.
 
    Query parameters in FastAPI are automatic —
    if the function parameter isn't a path parameter ({id}),
    FastAPI treats it as a query parameter.
    e.g. GET /history/sessions?doc_id=abc-123
    """
  sessions = list_sessions(doc_id=doc_id)
  return sessions

@router.get('/sessions/{session_id}' )
def get_one_session(session_id: str):
  """
    Returns one full session including all messages.
 
    Flutter calls this when the user taps a past conversation
    to re-open it. The messages array is used to rebuild
    the chat UI with the full history
  """
  session = get_session(session_id)
  if not session:
    raise HTTPException(status_code=404, detail=f"Session '{session_id}' not found")
  
  return session


@router.post('/sessions')
def save_one_session(session: dict):
  """
    Saves or updates a chat session from Flutter.
 
    Flutter calls this after every message exchange to keep
    the session persisted in Firestore.
 
    We accept a plain dict (not a typed schema) because the
    messages array contains SourceChunk objects which vary
    in structure — too rigid to schema-validate here.
 
    We do validate that session_id exists though — without it
    we can't store the document in Firestore.
    """
    
  if 'session_id' not in session:
    raise HTTPException(status_code=400, detail="session_id is required")
  
  if 'created_at' not in session:
    from datetime import datetime, timezone
    session['created_at'] = datetime.now(timezone.utc).isoformat()
  
  save_session(session)
  
  return {
    'message' : 'Session saved.',
    'session_id' : session['session_id']
  }

@router.delete('/sessions/{session_id}')
def delete_one_session(session_id: str):
  """
  Delete a chat session.
  
  """
  
  session = get_session(session_id)
  if not session:
    raise HTTPException(
      status_code=404,
      detail=f"Session '{session_id}' not found"
    )
    
  from firebase_admin import firestore
  db = firestore.client()
  db.collection('sessions').document(session_id).delete()
  
  return {
    'message' : 'Session deleted.',
    'session_id' : session_id
  }
  
# STATS -> for a dashboard or admin screen in FLutter

@router.get('/stats')
def get_state():
  """
  Return high-lvl stats about the user's lib.
  frontend use this to show:
    -> total docs uploaded
    -> breakdown by category
    -> Total chat session
    
    Example response:
    {
      'total_docs' : 12,
      'by_category' : {
        "legal" : 5, 'health' : 3, 'general' : 
      },
      'total_sessions' : 28
    }
  """
  docs = list_doc_records()
  sessions = list_sessions()
  
  # counting the docs by category
  
  by_category: dict[str, int] = {}
  for doc in docs:
    cat = doc.get('category', 'general')
    by_category[cat] = by_category.get(cat, 0) + 1
  
  return {
    'total_docs': len(docs),
    'by_category' : by_category,
    'total_sessions' : len(sessions)
  }
  
      