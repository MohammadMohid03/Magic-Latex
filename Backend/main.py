"""
main.py — MagicLatex FastAPI Application
=========================================
Start with:
    source venv/bin/activate
    uvicorn main:app --reload --host 0.0.0.0 --port 8000
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routes.convert import router as convert_router
from app.routes.health import router as health_router

app = FastAPI(
    title="MagicLatex API",
    description=(
        "Converts images of handwritten notes into PDF documents.\n\n"
        "**Pipeline:** Image → Google Gemini → LaTeX Source → pdflatex → PDF"
    ),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# ---------------------------------------------------------------------------
# CORS — allow all origins in development; restrict in production
# ---------------------------------------------------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],       # Change to your frontend URL in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Routers
# ---------------------------------------------------------------------------
app.include_router(health_router, prefix="/api", tags=["Health"])
app.include_router(convert_router, prefix="/api", tags=["Conversion"])


# ---------------------------------------------------------------------------
# Root redirect to docs
# ---------------------------------------------------------------------------
@app.get("/", include_in_schema=False)
async def root():
    from fastapi.responses import RedirectResponse
    return RedirectResponse(url="/docs")
