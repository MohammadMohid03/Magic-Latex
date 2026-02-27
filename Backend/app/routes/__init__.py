from fastapi import APIRouter

router = APIRouter()

# Import sub-routers here so the main app only needs to import this package
from app.routes import convert, health  # noqa: E402, F401
