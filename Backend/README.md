# 🪄 MagicLatex — Backend

Convert images of handwritten notes into beautifully compiled PDF documents using Google Gemini + LaTeX.

## Pipeline

```
Image Upload  →  Google Gemini (LLM)  →  LaTeX Source  →  pdflatex  →  PDF Download
```

---

## Project Structure

```
Magic-Latex/
├── main.py                  # FastAPI app entry point
├── requirements.txt
├── .env.example             # Copy to .env and add your API key
├── app/
│   ├── config.py            # Settings (loaded from .env)
│   ├── llm_service.py       # Gemini API integration
│   ├── latex_service.py     # pdflatex compilation
│   └── routes/
│       ├── convert.py       # POST /api/convert, /api/convert/latex-only
│       └── health.py        # GET /api/health
└── temp/                    # Auto-created; stores per-request LaTeX/PDF files
```

---

## Setup

### 1. Prerequisites

- **Python 3.10+**
- **pdflatex** — install via:
  ```bash
  sudo apt install texlive-latex-extra   # Ubuntu / Debian
  # or
  sudo dnf install texlive-latex         # Fedora
  ```
- **Google Gemini API key** — get one at https://aistudio.google.com/

### 2. Configure environment

```bash
cp .env.example .env
# Edit .env and set your GEMINI_API_KEY
```

### 3. Create & activate virtual environment

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 4. Run the server

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Open **http://localhost:8000/docs** to see interactive Swagger UI.

---

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/api/health` | Check service status |
| `POST` | `/api/convert` | Image → compiled PDF |
| `POST` | `/api/convert/latex-only` | Image → raw LaTeX JSON |

### POST `/api/convert`

**Request:** `multipart/form-data`
- `file`: image file (JPEG, PNG, WEBP, GIF, BMP, TIFF) — max 10 MB

**Response:** `application/pdf` — the compiled PDF as a file download.

**Example with curl:**
```bash
curl -X POST http://localhost:8000/api/convert \
  -F "file=@notes.jpg" \
  --output result.pdf
```

### POST `/api/convert/latex-only`

Same input as above, but returns JSON:
```json
{
  "filename": "notes.jpg",
  "latex": "\\documentclass[12pt]{article}\n...",
  "char_count": 1234
}
```

---

## Error Responses

| Status | Meaning |
|--------|---------|
| `400` | Empty file |
| `413` | File > 10 MB |
| `415` | Unsupported image type |
| `422` | Gemini returned non-LaTeX content |
| `500` | pdflatex compilation failed (log included in detail) |
| `502` | Gemini API error |

---

## Notes

- `pdflatex` is run **twice** per request to resolve cross-references.
- Each request gets its own isolated temp directory; files are auto-deleted after the PDF is streamed.
- Concurrent requests are fully supported (async).