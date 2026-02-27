import os
from dotenv import load_dotenv

load_dotenv()


class Settings:
    GROQ_API_KEY: str = os.getenv("GROQ_API_KEY", "")

    # Vision-capable Groq model for image → LaTeX extraction
    GROQ_VISION_MODEL: str = "meta-llama/llama-4-scout-17b-16e-instruct"

    # Text-only model used for the LaTeX fix/repair node (faster & cheaper)
    GROQ_TEXT_MODEL: str = "llama-3.3-70b-versatile"

    # Max times the graph will attempt to auto-fix bad LaTeX before giving up
    MAX_FIX_RETRIES: int = 2

    # Where temporary LaTeX / PDF files are stored during compilation
    TEMP_DIR: str = os.path.join(os.path.dirname(__file__), "..", "temp")

    # LaTeX compiler — must be on PATH (install: sudo apt install texlive-latex-extra)
    LATEX_CMD: str = "pdflatex"

    # Seconds to wait for pdflatex before timing out
    LATEX_TIMEOUT: int = 60


settings = Settings()

# Ensure temp dir exists at import time
os.makedirs(settings.TEMP_DIR, exist_ok=True)
