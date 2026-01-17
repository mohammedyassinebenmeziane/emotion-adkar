# Environment Setup Guide

This file explains how to set up the required environment variables for the Emotion Adkar Backend.

## Required Environment Variables

Create a `.env` file in the `emotion_adkar_backend` directory with the following variables:

```env
# MongoDB Configuration
MONGO_URI=mongodb://localhost:27017
DB_NAME=emotion_adkar

# JWT Configuration
JWT_SECRET=your-secret-key-change-this-in-production
JWT_ALGORITHM=HS256
JWT_EXP_MIN=1440
```

## Configuration Details

### MongoDB Configuration
- **MONGO_URI**: Connection string for your MongoDB database
  - Local MongoDB: `mongodb://localhost:27017`
  - MongoDB Atlas: `mongodb+srv://username:password@cluster.mongodb.net/`
- **DB_NAME**: Name of your MongoDB database (e.g., `emotion_adkar`)

### JWT Configuration
- **JWT_SECRET**: Secret key used to sign JWT tokens (use a strong, random string in production)
- **JWT_ALGORITHM**: Algorithm for JWT signing (default: `HS256`)
- **JWT_EXP_MIN**: Token expiration time in minutes (default: 1440 = 24 hours)

## Setup Steps

1. Copy this template and create a `.env` file:
   ```powershell
   cd emotion_adkar_backend
   # Create .env file and add the variables above
   ```

2. Update the values according to your MongoDB setup

3. Make sure MongoDB is running and accessible

4. Restart your FastAPI server after creating/updating the `.env` file

## Troubleshooting

If you get errors about missing environment variables:
- Ensure the `.env` file is in the `emotion_adkar_backend` directory
- Check that all required variables are set
- Verify MongoDB connection string is correct
- Restart the server after making changes






