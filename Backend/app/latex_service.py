"""
latex_service.py
================
Writes a LaTeX string to a temp file, runs pdflatex, and returns the
path to the compiled PDF.
"""

import asyncio
import os
import shutil
import subprocess
import tempfile
import uuid

from app.config import settings


async def compile_latex(latex_source: str) -> str:
    """
    Compile a LaTeX string to a PDF file.

    Creates an isolated temporary directory for each job so that
    concurrent requests don't interfere with each other.

    Args:
        latex_source: Full LaTeX source code (must be a complete document).

    Returns:
        Absolute path to the compiled PDF file.

    Raises:
        RuntimeError: If pdflatex is missing or compilation fails.
        FileNotFoundError: If the PDF was not produced (compilation error).
    """
    # Check that pdflatex is available
    if shutil.which(settings.LATEX_CMD) is None:
        raise RuntimeError(
            f"'{settings.LATEX_CMD}' not found on PATH. "
            "Install it with: sudo apt install texlive-latex-extra"
        )

    job_id = uuid.uuid4().hex
    job_dir = os.path.join(settings.TEMP_DIR, job_id)
    os.makedirs(job_dir, exist_ok=True)

    tex_file = os.path.join(job_dir, "document.tex")
    pdf_file = os.path.join(job_dir, "document.pdf")

    # Write the LaTeX source
    with open(tex_file, "w", encoding="utf-8") as f:
        f.write(latex_source)

    # Run pdflatex twice (to resolve references / table of contents)
    for run in range(2):
        await _run_pdflatex(tex_file, job_dir, run + 1)

    if not os.path.exists(pdf_file):
        log_path = os.path.join(job_dir, "document.log")
        log_snippet = _read_log(log_path)
        raise FileNotFoundError(
            f"pdflatex ran but no PDF was produced. "
            f"LaTeX log (last 2000 chars):\n{log_snippet}"
        )

    return pdf_file


async def _run_pdflatex(tex_file: str, job_dir: str, run_number: int) -> None:
    """Run pdflatex as a subprocess asynchronously."""
    cmd = [
        settings.LATEX_CMD,
        "-interaction=nonstopmode",  # Don't pause on errors
        "-halt-on-error",            # Exit with non-zero code on first error
        "-output-directory", job_dir,
        tex_file,
    ]

    try:
        proc = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.STDOUT,
            cwd=job_dir,
        )
        stdout, _ = await asyncio.wait_for(
            proc.communicate(), timeout=settings.LATEX_TIMEOUT
        )
    except asyncio.TimeoutError:
        proc.kill()
        raise RuntimeError(
            f"pdflatex timed out after {settings.LATEX_TIMEOUT}s (run {run_number})"
        )

    if proc.returncode != 0:
        log_path = os.path.join(job_dir, "document.log")
        log_snippet = _read_log(log_path)
        raise RuntimeError(
            f"pdflatex failed on run {run_number} "
            f"(exit code {proc.returncode}).\n"
            f"LaTeX log (last 2000 chars):\n{log_snippet}"
        )


def cleanup_job(pdf_path: str) -> None:
    """
    Delete the entire job directory after the PDF has been streamed.
    Call this in a BackgroundTask after sending the response.
    """
    job_dir = os.path.dirname(pdf_path)
    shutil.rmtree(job_dir, ignore_errors=True)


def _read_log(log_path: str, tail_chars: int = 2000) -> str:
    """Return the last `tail_chars` characters of a LaTeX log file."""
    if not os.path.exists(log_path):
        return "(log file not found)"
    with open(log_path, "r", encoding="utf-8", errors="replace") as f:
        content = f.read()
    return content[-tail_chars:] if len(content) > tail_chars else content
