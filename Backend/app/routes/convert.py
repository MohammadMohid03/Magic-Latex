"""
routes/convert.py
=================
POST /api/convert — the main endpoint.

Flow:
  1. Receive image upload
  2. Send to Gemini → get LaTeX source
  3. Compile LaTeX → PDF
  4. Stream PDF back to the client
  5. Clean up temp files in the background
"""

import os
from fastapi import APIRouter, File, HTTPException, UploadFile, BackgroundTasks
from fastapi.responses import FileResponse, JSONResponse

from app.llm_service import image_to_latex
from app.latex_service import compile_latex, cleanup_job

router = APIRouter()

ALLOWED_MIME_TYPES = {
    "image/jpeg",
    "image/jpg",
    "image/png",
    "image/webp",
    "image/gif",
    "image/bmp",
    "image/tiff",
}

MAX_FILE_SIZE_MB = 10
MAX_FILE_SIZE_BYTES = MAX_FILE_SIZE_MB * 1024 * 1024


@router.post(
    "/convert",
    summary="Convert handwritten notes image to PDF",
    response_description="A compiled PDF file of the extracted LaTeX content",
)
async def convert_image_to_pdf(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(..., description="Image of handwritten notes (JPEG, PNG, WEBP, etc.)"),
):
    """
    Upload an image of handwritten notes.

    The backend will:
    - Extract text and equations using Google Gemini
    - Convert the content to a complete LaTeX document
    - Compile the LaTeX to a PDF
    - Return the PDF as a downloadable file
    """
    # --- Validate file type ---
    content_type = file.content_type or ""
    if content_type not in ALLOWED_MIME_TYPES:
        raise HTTPException(
            status_code=415,
            detail=(
                f"Unsupported file type: '{content_type}'. "
                f"Accepted types: {sorted(ALLOWED_MIME_TYPES)}"
            ),
        )

    # --- Read file bytes ---
    image_bytes = await file.read()
    if len(image_bytes) == 0:
        raise HTTPException(status_code=400, detail="Uploaded file is empty.")
    if len(image_bytes) > MAX_FILE_SIZE_BYTES:
        raise HTTPException(
            status_code=413,
            detail=f"File too large. Maximum allowed size is {MAX_FILE_SIZE_MB} MB.",
        )

    # --- Step 1: Image → LaTeX via Gemini ---
    try:
        latex_source = await image_to_latex(image_bytes, content_type)
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc))
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc))

    # --- Step 2: LaTeX → PDF ---
    try:
        pdf_path = await compile_latex(latex_source)
    except RuntimeError as exc:
        raise HTTPException(status_code=500, detail=str(exc))
    except FileNotFoundError as exc:
        raise HTTPException(status_code=500, detail=str(exc))

    # Schedule temp-dir cleanup AFTER the response is fully sent
    background_tasks.add_task(cleanup_job, pdf_path)

    original_name = os.path.splitext(file.filename or "notes")[0]
    download_name = f"{original_name}_converted.pdf"

    return FileResponse(
        path=pdf_path,
        media_type="application/pdf",
        filename=download_name,
        headers={"X-LaTeX-Source-Length": str(len(latex_source))},
    )


@router.post(
    "/convert/latex-only",
    summary="Extract LaTeX source without compiling",
    response_description="JSON containing the extracted LaTeX source code",
)
async def get_latex_source(
    file: UploadFile = File(..., description="Image of handwritten notes"),
):
    """
    Same as /convert but returns the raw LaTeX source as JSON instead of a PDF.
    Useful for previewing / editing before compilation.
    """
    content_type = file.content_type or ""
    if content_type not in ALLOWED_MIME_TYPES:
        raise HTTPException(status_code=415, detail=f"Unsupported file type: '{content_type}'.")

    image_bytes = await file.read()
    if not image_bytes:
        raise HTTPException(status_code=400, detail="Uploaded file is empty.")

    try:
        latex_source = await image_to_latex(image_bytes, content_type)
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc))
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc))

    return JSONResponse(
        content={
            "filename": file.filename,
            "latex": latex_source,
            "char_count": len(latex_source),
        }
    )
