import os
from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME")

if not MONGO_URI:
    raise ValueError("MONGO_URI is not set in .env file")

if not DB_NAME:
    raise ValueError("DB_NAME is not set in .env file")

client = AsyncIOMotorClient(MONGO_URI)
db = client[DB_NAME]
users_collection = db["users"]
emotion_content_collection = db["emotion_content"]

print(f"Connected to MongoDB at {MONGO_URI}, Database: {DB_NAME}")
