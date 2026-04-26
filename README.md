# DocMind

Chat with your documents. Upload a PDF, image, or text file — DocMind reads it, understands it, and answers your questions with sources.

---

## What it does

- Upload PDFs, scanned images, or text files
- Automatically classifies the document (legal, health, finance, etc.)
- Chunks and embeds the content into a vector database
- Answers questions using only what's in your document
- Shows exactly which passage the answer came from
- Supports asking questions across multiple documents at once
- Streams answers token by token like ChatGPT

---

## Stack

**Backend**
- FastAPI on Render (free tier) : Not deployed as of now.
- Google Gemini 2.5 Flash Lite — answers + document classification
- `sentence-transformers/all-MiniLM-L6-v2` — local embeddings, zero API cost
- Qdrant Cloud — vector search
- Firestore — document metadata and chat sessions
- Cloudinary — original file storage

**Flutter app**
- Riverpod — state management
- Dio — HTTP + SSE streaming
- Dark mode with Obsidian Theme
- Responsive layout (mobile, tablet, web)

---

## How it works

```
Upload file
  → extract text (PyMuPDF / Tesseract OCR)
  → classify document category (Gemini)
  → split into overlapping chunks
  → embed each chunk (local model, no API cost)
  → store vectors in Qdrant

Ask a question
  → embed the question
  → find top 5 matching chunks in Qdrant
  → inject category persona into prompt
  → stream answer from Gemini
  → show source passages in UI
```

---

## Project structure

```
docmind/
├── backend/
│   ├── main.py
│   ├── models/schemas.py
│   ├── routers/
│   │   ├── ingest.py
│   │   ├── query.py
│   │   └── history.py
│   └── services/
│       ├── parser.py        # PDF + OCR
│       ├── chunker.py       # text splitting
│       ├── embedder.py      # sentence-transformers
│       ├── classifier.py    # Gemini zero-shot
│       ├── vector_store.py  # Qdrant
│       ├── firebase_store.py # Firestore + Cloudinary
│       └── llm.py           # Gemini RAG + streaming
│
└── flutter_app/
    └── lib/
        ├── core/            # theme, constants, API client
        ├── providers/       # Riverpod state
        ├── widgets/         # shared UI components
        └── features/        # upload, chat, documents screens
```

---

## Running locally

**Backend**

```bash
cd backend
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# fill in your keys
uvicorn main:app --reload
```


**Flutter**

```bash
cd flutter_app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

---

## Environment variables

```
GEMINI_API_KEY
QDRANT_URL
QDRANT_API_KEY
QDRANT_COLLECTION
FIREBASE_CREDENTIALS_PATH
CLOUDINARY_CLOUD_NAME
CLOUDINARY_API_KEY
CLOUDINARY_API_SECRET
```

All free tier. No credit card required.

---

## API endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/ingest` | Upload and process a document |
| POST | `/query` | Ask a question, get full answer |
| POST | `/query/stream` | Ask a question, stream the answer (SSE) |
| POST | `/query/multi` | Ask across multiple documents |
| GET | `/history/docs` | List all documents |
| DELETE | `/history/docs/{id}` | Delete a document |
| GET | `/history/sessions` | List chat sessions |
| POST | `/history/sessions` | Save a session |
| GET | `/health` | Service status |

---

## Supported file types

PDF · JPG · PNG · WEBP · TXT · MD — max 20MB

---

## Built by

[@sumiittt_07](https://x.com/sumiittt_07) — built in public
