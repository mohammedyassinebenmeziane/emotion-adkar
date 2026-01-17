from fastapi import APIRouter, UploadFile, File, HTTPException, status
from services.emotion_service import analyze_emotion

router = APIRouter(prefix="/emotion", tags=["emotion"])

@router.post("/predict")
async def predict_emotion_endpoint(image: UploadFile = File(...)):
    """
    Upload an image file to detect emotion.
    """
    # Validate file type
    if image.content_type not in ["image/jpeg", "image/png", "image/jpg"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid file type. Only JPEG and PNG are supported."
        )
    
    try:
        # Read file bytes
        file_bytes = await image.read()
        
        # Analyze emotion
        result = await analyze_emotion(file_bytes)
        
        # Add text direction metadata for proper rendering
        result["text_direction"] = "rtl"  # Right-to-left for Arabic text
        result["text_encoding"] = "utf-8"
        
        return result
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error processing image: {str(e)}"
        )
