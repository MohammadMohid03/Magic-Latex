"""
llm_service.py — LangGraph pipeline: Image → LaTeX
====================================================

Graph nodes
-----------
1. extract_latex      Groq vision model reads the image and produces a full
                      LaTeX document.
2. validate_latex     Checks the output for basic LaTeX validity (no LLM call).
3. fix_latex          If validation fails, a text-only Groq model repairs the
                      LaTeX. Retried up to MAX_FIX_RETRIES times.

Graph edges
-----------
  START ──► extract_latex ──► validate_latex ──► [valid]   ──► END
                                               └─ [invalid] ──► fix_latex ──► validate_latex
                                                                   (loop, capped by retry_count)
"""

import base64
import re
from typing import Optional

from langchain_core.messages import HumanMessage, SystemMessage
from langchain_groq import ChatGroq
from langgraph.graph import END, START, StateGraph
from typing_extensions import TypedDict

from app.config import settings

# ---------------------------------------------------------------------------
# Prompts
# ---------------------------------------------------------------------------

EXTRACTION_SYSTEM_PROMPT = """\
You are an expert OCR and LaTeX typesetter specialising in handwritten academic notes.

Your task:
1. Read every piece of text, equation, diagram, table, or list in the image.
2. Return a SINGLE, COMPLETE, COMPILABLE LaTeX document — nothing else.

Hard rules:
- Output ONLY raw LaTeX. No markdown fences, no explanations.
- Start with \\documentclass and end with \\end{document}.
- Use \\documentclass[12pt]{article}.
- Always include these packages:
    \\usepackage[utf8]{inputenc}
    \\usepackage[T1]{fontenc}
    \\usepackage{amsmath, amssymb, amsthm}
    \\usepackage{geometry}
    \\usepackage{graphicx}
    \\usepackage{enumitem}
    \\usepackage{hyperref}
    \\geometry{margin=1in}
- Format all maths using $...$ (inline) or \\[...\\] / equation environment (display).
- Convert headings → \\section / \\subsection, bullet lists → itemize, numbered lists → enumerate.
- If a diagram cannot be reproduced, write: \\textit{[Diagram: <description>]}
- Escape all LaTeX special characters: # $ % & _ { } ^ ~ \\
- The document must compile with pdflatex without errors.
"""

EXTRACTION_USER_PROMPT = (
    "Convert the handwritten notes in this image into a complete LaTeX document."
)

FIX_SYSTEM_PROMPT = """\
You are a LaTeX expert. You will be given a broken LaTeX document and an error description.
Fix ALL issues so the document compiles cleanly with pdflatex.

Rules:
- Return ONLY raw LaTeX — no explanations, no markdown fences.
- Keep all the original content; only fix syntax / compilation errors.
- The output must start with \\documentclass and end with \\end{document}.
"""


# ---------------------------------------------------------------------------
# LangGraph state
# ---------------------------------------------------------------------------

class LatexState(TypedDict):
    image_bytes: bytes          # raw bytes of the uploaded image
    mime_type: str              # e.g. "image/jpeg"
    latex_source: str           # LaTeX produced / repaired so far
    is_valid: bool              # result of latest validation
    validation_error: str       # description of what is wrong (empty if valid)
    retry_count: int            # how many fix attempts have been made
    error: Optional[str]        # fatal error message (stops the graph)


# ---------------------------------------------------------------------------
# Node helpers
# ---------------------------------------------------------------------------

def _make_vision_model() -> ChatGroq:
    if not settings.GROQ_API_KEY:
        raise RuntimeError(
            "GROQ_API_KEY is not set. Add it to your .env file."
        )
    return ChatGroq(
        model=settings.GROQ_VISION_MODEL,
        api_key=settings.GROQ_API_KEY,
        temperature=0.1,
    )


def _make_text_model() -> ChatGroq:
    if not settings.GROQ_API_KEY:
        raise RuntimeError(
            "GROQ_API_KEY is not set. Add it to your .env file."
        )
    return ChatGroq(
        model=settings.GROQ_TEXT_MODEL,
        api_key=settings.GROQ_API_KEY,
        temperature=0.15,
    )


def _strip_code_fences(text: str) -> str:
    """Remove ```latex ... ``` or ``` ... ``` wrappers if the model adds them."""
    pattern = r"^```[a-zA-Z]*\n?(.*?)```$"
    match = re.match(pattern, text, re.DOTALL)
    return match.group(1).strip() if match else text


def _validate(latex: str) -> tuple[bool, str]:
    """
    Lightweight, heuristic LaTeX validation. Returns (is_valid, error_msg).
    We intentionally keep this cheap (no subprocess) — full compilation
    happens in latex_service.py afterwards.
    """
    if not latex.strip():
        return False, "LaTeX output is empty."

    if "\\documentclass" not in latex:
        return False, "Missing \\documentclass declaration."

    if "\\begin{document}" not in latex:
        return False, "Missing \\begin{document}."

    if "\\end{document}" not in latex:
        return False, "Missing \\end{document}."

    # Detect unescaped bare ampersands outside of tabular-like environments
    # (a common LLM mistake)
    unescaped_amp = re.search(r"(?<!\\)&(?![^{]*})", latex)
    if unescaped_amp:
        return False, (
            "Found an unescaped '&' character. "
            "Outside of tabular/align environments, use \\& instead."
        )

    return True, ""


# ---------------------------------------------------------------------------
# Graph nodes
# ---------------------------------------------------------------------------

def node_extract_latex(state: LatexState) -> dict:
    """
    Node 1: Send the image to Groq vision model and get raw LaTeX back.
    """
    b64_image = base64.b64encode(state["image_bytes"]).decode("utf-8")

    human_message = HumanMessage(
        content=[
            {"type": "text", "text": EXTRACTION_USER_PROMPT},
            {
                "type": "image_url",
                "image_url": {
                    "url": f"data:{state['mime_type']};base64,{b64_image}"
                },
            },
        ]
    )

    try:
        model = _make_vision_model()
        response = model.invoke([
            SystemMessage(content=EXTRACTION_SYSTEM_PROMPT),
            human_message,
        ])
        latex = _strip_code_fences(response.content.strip())
    except Exception as exc:
        return {"error": f"Groq vision API error: {exc}"}

    return {
        "latex_source": latex,
        "retry_count": 0,
        "error": None,
    }


def node_validate_latex(state: LatexState) -> dict:
    """
    Node 2: Heuristic validation of the LaTeX string.
    No LLM call — just pattern checks.
    """
    is_valid, error_msg = _validate(state.get("latex_source", ""))
    return {
        "is_valid": is_valid,
        "validation_error": error_msg,
    }


def node_fix_latex(state: LatexState) -> dict:
    """
    Node 3: Ask the text model to repair the LaTeX based on the validation error.
    """
    fix_prompt = (
        f"The following LaTeX document has an error:\n\n"
        f"ERROR: {state['validation_error']}\n\n"
        f"BROKEN LATEX:\n{state['latex_source']}\n\n"
        f"Return the corrected, complete LaTeX document."
    )

    try:
        model = _make_text_model()
        response = model.invoke([
            SystemMessage(content=FIX_SYSTEM_PROMPT),
            HumanMessage(content=fix_prompt),
        ])
        fixed_latex = _strip_code_fences(response.content.strip())
    except Exception as exc:
        return {"error": f"Groq fix API error: {exc}"}

    return {
        "latex_source": fixed_latex,
        "retry_count": state["retry_count"] + 1,
        "error": None,
    }


# ---------------------------------------------------------------------------
# Conditional edge routing
# ---------------------------------------------------------------------------

def route_after_validation(state: LatexState) -> str:
    """
    After validation:
    - If valid → end the graph.
    - If invalid and retries remain → go to fix node.
    - If invalid and retries exhausted → end (caller will see is_valid=False).
    """
    if state.get("error"):
        return END

    if state["is_valid"]:
        return END

    if state["retry_count"] < settings.MAX_FIX_RETRIES:
        return "fix_latex"

    # Retries exhausted — return what we have; latex_service will catch errors
    return END


def route_after_extraction(state: LatexState) -> str:
    """If extraction hit a fatal error, short-circuit to END."""
    if state.get("error"):
        return END
    return "validate_latex"


# ---------------------------------------------------------------------------
# Build the LangGraph
# ---------------------------------------------------------------------------

def _build_graph() -> StateGraph:
    graph = StateGraph(LatexState)

    graph.add_node("extract_latex", node_extract_latex)
    graph.add_node("validate_latex", node_validate_latex)
    graph.add_node("fix_latex", node_fix_latex)

    graph.add_edge(START, "extract_latex")

    graph.add_conditional_edges(
        "extract_latex",
        route_after_extraction,
        {
            "validate_latex": "validate_latex",
            END: END,
        },
    )

    graph.add_conditional_edges(
        "validate_latex",
        route_after_validation,
        {
            "fix_latex": "fix_latex",
            END: END,
        },
    )

    # After fixing, always re-validate
    graph.add_edge("fix_latex", "validate_latex")

    return graph.compile()


# Compiled graph — built once at module load time
_latex_graph = _build_graph()


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

async def image_to_latex(image_bytes: bytes, mime_type: str) -> str:
    """
    Run the LangGraph pipeline: image bytes → complete LaTeX document string.

    Args:
        image_bytes: Raw bytes of the uploaded image.
        mime_type:   MIME type (e.g. 'image/jpeg').

    Returns:
        A complete LaTeX document as a string.

    Raises:
        RuntimeError: If Groq API fails or config is missing.
        ValueError:   If LaTeX could not be extracted/validated after retries.
    """
    initial_state: LatexState = {
        "image_bytes": image_bytes,
        "mime_type": mime_type,
        "latex_source": "",
        "is_valid": False,
        "validation_error": "",
        "retry_count": 0,
        "error": None,
    }

    # LangGraph's compiled graph is synchronous; run in the event loop
    import asyncio
    final_state = await asyncio.get_event_loop().run_in_executor(
        None, _latex_graph.invoke, initial_state
    )

    # Surface any fatal errors that occurred inside the graph
    if final_state.get("error"):
        raise RuntimeError(final_state["error"])

    latex = final_state.get("latex_source", "")

    if not latex:
        raise ValueError("LangGraph pipeline produced no LaTeX output.")

    if not final_state.get("is_valid"):
        # Not valid after all retries — still return it; pdflatex will give
        # a descriptive error if it can't compile.
        pass

    return latex
