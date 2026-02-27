from fastapi import APIRouter
from fastapi.responses import JSONResponse
import shutil
from app.config import settings

router = APIRouter()


@router.get("/health", summary="Health check", tags=["Health"])
async def health_check():
    """Returns service status and capability flags."""
    pdflatex_available = shutil.which(settings.LATEX_CMD) is not None
    gemini_configured = bool(settings.GEMINI_API_KEY)

    return JSONResponse(
        content={
            "status": "ok",
            "gemini_configured": gemini_configured,
            "pdflatex_available": pdflatex_available,
            "model": settings.GEMINI_MODEL,
        }
    )
