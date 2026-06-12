import os

from fastapi import APIRouter
from fastapi import Depends
from fastapi import UploadFile
from fastapi import File
from fastapi import HTTPException

from pydantic import BaseModel

from app.rag.rag_pipeline import process_pdf
from app.rag.rag_pipeline import ask_pdf
from app.core.security import get_current_user

router = APIRouter()

UPLOAD_DIR = "uploads"

os.makedirs(UPLOAD_DIR, exist_ok=True)

class PDFQuestion(BaseModel):
    question: str

@router.post("/upload-pdf")
async def upload_pdf(file: UploadFile = File(...), user=Depends(get_current_user)):
    try:
        if not file.filename.endswith('.pdf'):
            raise HTTPException(status_code=400, detail="File must be a PDF")

        file_path = f"{UPLOAD_DIR}/{file.filename}"

        with open(file_path, "wb") as buffer:
            buffer.write(await file.read())

        process_pdf(file_path)

        return {
            "message": "PDF uploaded and processed successfully",
            "filename": file.filename
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")

@router.post("/ask-pdf")
def ask_question(request: PDFQuestion, user=Depends(get_current_user)):
    try:
        if not request.question or request.question.strip() == "":
            raise HTTPException(status_code=400, detail="Question cannot be empty")

        result = ask_pdf(request.question)

        if not result or result.strip() == "":
            raise HTTPException(status_code=500, detail="Could not process question")

        return {
            "answer": result,
            "question": request.question
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to process question: {str(e)}")
