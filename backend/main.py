from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
import os

load_dotenv()

app = FastAPI(
  title = 'DocMind API',
  description = 'API for DocMind, a document analysis and question-answering system.',
  version = os.getenv('API_VERSION', '1.0.0')
  
)



# CORS = Cross-Origin Resource Sharing
# Wwithout this, you flutter app cannot talk to this backkend because browsers block requests to different domains

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],       # In production, replace * with your app's domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routes
@app.get('/')
def root():
    # fastAPI automatically convets the dict to JSON
    return {
      'app': 'DocMind API',
      'status' : 'running',
      'version': os.getenv('API_VERSION', 'unknown')
    }

@app.get('/health')
def health():
    # render pings this URL to know the app is alive
    return {
      'status' : 'ok',
      'version': os.getenv('API_VERSION', '1.0.0')
    }