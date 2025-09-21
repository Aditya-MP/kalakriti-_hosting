
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer
import uvicorn
from dotenv import load_dotenv
import logging
import time
import asyncio
from contextlib import asynccontextmanager

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Load environment variables from .env file
load_dotenv()



def load_ai_model(app: FastAPI):
    """Load the AI model and tokenizer synchronously"""
    logger.info("Loading model and tokenizer...")
    try:
        model_name = "google/gemma-3-270m-it"
        HUGGING_FACE_TOKEN = os.environ.get('HUGGING_FACE_TOKEN')
        
        if not HUGGING_FACE_TOKEN:
            logger.error("HUGGING_FACE_TOKEN environment variable not set")
            raise ValueError("HUGGING_FACE_TOKEN is required")

        logger.info(f"Using model: {model_name}")
        
        # Load tokenizer and model with optimizations
        tokenizer = AutoTokenizer.from_pretrained(
            model_name,
            token=HUGGING_FACE_TOKEN
        )
        logger.info("Tokenizer loaded successfully")
        
        # Set padding token if not set
        if tokenizer.pad_token is None:
            tokenizer.pad_token = tokenizer.eos_token
        
        # Load model with optimizations for faster inference
        model = AutoModelForCausalLM.from_pretrained(
            model_name,
            token=HUGGING_FACE_TOKEN,
            torch_dtype=torch.float16 if torch.cuda.is_available() else torch.float32,
            device_map="auto" if torch.cuda.is_available() else "cpu",
            low_cpu_mem_usage=True,
        )
        
        logger.info("Model loaded successfully!")
        
        # Store in app state
        app.state.model = model
        app.state.tokenizer = tokenizer
        app.state.model_loaded = True
        logger.info("AI model is ready for use!")
        
    except Exception as e:
        logger.error(f"Error loading model: {str(e)}")
        app.state.model_loaded = False
        raise e

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan context manager for startup/shutdown events"""
    # Initialize variables
    app.state.model = None
    app.state.tokenizer = None
    app.state.model_loaded = False
    
    # Startup - call synchronous load
    try:
        load_ai_model(app)
    except Exception as e:
        logger.error(f"Failed to load model: {str(e)}")
    
    yield
    
    # Shutdown - safely clean up resources
    try:
        if hasattr(app.state, 'model') and app.state.model is not None:
            del app.state.model
        if hasattr(app.state, 'tokenizer') and app.state.tokenizer is not None:
            del app.state.tokenizer
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
        logger.info("Model resources cleaned up")
    except Exception as e:
        logger.error(f"Error during cleanup: {str(e)}")

app = FastAPI(
    title="Kalakriti Backend API", 
    version="1.0.0",
    lifespan=lifespan
)

# Configure CORS - allow all origins for development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development
=======
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import torch
from transformers import AutoModelForCausalLM, AutoTokenizer
import uvicorn

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
>>>>>>> 7a6d40a (Initial project push)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Pydantic model for request validation
class StoryRequest(BaseModel):
    prompt: str

def get_fallback_story(prompt: str):
    """Generate a meaningful fallback story"""
    return f"""In the creative journey of {prompt}, a passionate artist discovered the beauty of handmade craftsmanship. Each piece created tells a story of dedication, patience, and artistic vision.

The work represents the timeless tradition of artisanal excellence, blending traditional techniques with contemporary designs to create something truly magical and unique."""

def generate_ai_story_sync(app: FastAPI, user_prompt: str):
    """Synchronous story generation function"""
    try:
        # Check if model is available
        if not hasattr(app.state, 'model_loaded') or not app.state.model_loaded:
            raise Exception("Model not loaded")
            
        # Use a more conversational prompt that's less likely to be repeated
        formatted_prompt = f"""Tell me a beautiful story about {user_prompt}. 
        Make it descriptive, engaging, and focus on the artistic and cultural significance.
        Here's the story:"""
        
        # Tokenize input
        inputs = app.state.tokenizer(formatted_prompt, return_tensors="pt", truncation=True, max_length=512)
        
        # Move to appropriate device
        device = "cuda" if torch.cuda.is_available() else "cpu"
        inputs = inputs.to(device)
        
        # Generate response with optimized parameters
        with torch.no_grad():
            outputs = app.state.model.generate(
                **inputs,
                max_new_tokens=300,
                do_sample=True,
                temperature=0.85,
                top_k=60,
                top_p=0.92,
                pad_token_id=app.state.tokenizer.eos_token_id,
                eos_token_id=app.state.tokenizer.eos_token_id,
                repetition_penalty=1.3,
            )
        
        # Decode the generated text
        generated_text = app.state.tokenizer.decode(outputs[0], skip_special_tokens=True)
        
        # Remove the prompt from the generated text if it's included
        if formatted_prompt in generated_text:
            generated_text = generated_text.replace(formatted_prompt, "").strip()
        
        return generated_text
        
    except Exception as e:
        logger.error(f"Error in sync generation: {str(e)}")
        raise e
=======
# Initialize variables
model = None
tokenizer = None

print("Loading model and tokenizer...")
try:
    model_name = "google/gemma-3-270m-it"
    import os
    hf_token = os.getenv("HF_TOKEN", "")  # Use environment variable, default to empty string

    # Load tokenizer and model
    tokenizer = AutoTokenizer.from_pretrained(model_name, token=hf_token)
    model = AutoModelForCausalLM.from_pretrained(
        model_name,
    token=hf_token,
        torch_dtype=torch.float32,  # Using float32 for better compatibility
        device_map="auto"
    )
    print("Model and tokenizer loaded successfully!")
except Exception as e:
    print(f"Error loading model: {e}")
    model = None
    tokenizer = None
>>>>>>> 7a6d40a (Initial project push)

@app.get("/")
async def root():
    return {"message": "Kalakriti Backend API is running!"}

@app.get("/health")
async def health_check():

    return {
        "status": "healthy", 
        "model_loaded": model_loaded,
        "cuda_available": torch.cuda.is_available(),
        "timestamp": time.time()
    }

@app.post("/generate-story")
async def generate_story(request: StoryRequest):
    try:
        # Check if prompt is provided
        if not request.prompt or not request.prompt.strip():
            return {
                "story": "Please provide a valid prompt for story generation.",
                "status": "error",
                "model_used": False
            }
        
        user_prompt = request.prompt.strip()
        logger.info(f"Received story generation request: {user_prompt[:50]}...")

        # Check if model is loaded
        if not hasattr(app.state, 'model_loaded') or not app.state.model_loaded:
            logger.warning("Model not available, using fallback story")
            return {
                "story": get_fallback_story(user_prompt),
                "status": "success",
                "model_used": False
            }

        # Use asyncio to run the synchronous generation with timeout
        try:
            generated_text = await asyncio.wait_for(
                asyncio.to_thread(generate_ai_story_sync, app, user_prompt),
                timeout=45.0  # 45 seconds timeout
            )
            
            logger.info(f"Successfully generated story of length: {len(generated_text)}")
            
            return {
                "story": generated_text,
                "status": "success",
                "model_used": True
            }
            
        except asyncio.TimeoutError:
            logger.warning("AI generation timeout - using fallback story")
            return {
                "story": get_fallback_story(user_prompt),
                "status": "success",
                "model_used": False,
                "note": "AI generation took too long, used fallback content"
            }
        except Exception as e:
            logger.error(f"Generation error: {str(e)}")
            return {
                "story": get_fallback_story(user_prompt),
                "status": "success",
                "model_used": False,
                "error": str(e)
            }
    
    except Exception as error:
        logger.error(f"Story generation error: {str(error)}")
        return {
            "story": get_fallback_story(request.prompt),
            "status": "success",
            "model_used": False,
            "error": str(error)
        }

@app.post("/reload-model")
async def reload_model():
    """Endpoint to reload the model if needed"""
    try:
        # Cleanup old model
        if hasattr(app.state, 'model') and app.state.model is not None:
            del app.state.model
        if hasattr(app.state, 'tokenizer') and app.state.tokenizer is not None:
            del app.state.tokenizer
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
        
        # Load new model
        load_ai_model(app)
        
        model_loaded = hasattr(app.state, 'model_loaded') and app.state.model_loaded
        
        return {
            "status": "success",
            "model_loaded": model_loaded,
            "message": "Model reloaded successfully" if model_loaded else "Failed to reload model"
        }
    except Exception as e:
        logger.error(f"Error reloading model: {str(e)}")
        return {
            "status": "error",
            "message": f"Failed to reload model: {str(e)}"
        }

@app.get("/model-status")
async def model_status():
    """Check detailed model status"""
    model_loaded = hasattr(app.state, 'model_loaded') and app.state.model_loaded
    device = str(app.state.model.device) if model_loaded and hasattr(app.state, 'model') and app.state.model is not None else "None"
    return {
        "model_loaded": model_loaded,
        "model_name": "google/gemma-3-270m-it" if model_loaded else "None",
        "device": device,
        "cuda_available": torch.cuda.is_available(),
        "memory_allocated": torch.cuda.memory_allocated() if torch.cuda.is_available() else 0,
    [from fastapi import FastAPI

if __name__ == "__main__":
    logger.info("\nStarting Kalakriti Backend API...")
    logger.info("Access the API at: http://localhost:8080")
    logger.info("API documentation at: http://localhost:8080/docs")
    logger.info("Ngrok URL: https://76a3c0da9fe6.ngrok-free.app")
    uvicorn.run(app, host="0.0.0.0", port=8080)
=======
    return {"status": "healthy", "model_loaded": model is not None}

@app.post("/generate-story")
async def generate_story(prompt: dict):
    try:
        # Check if prompt is provided
        if "prompt" not in prompt:
            raise HTTPException(status_code=400, detail="Prompt is required")

        # Check if model is loaded
        if model is None or tokenizer is None:
            raise HTTPException(status_code=503, detail="Model not loaded yet")

        # Format the prompt for the model
        formatted_prompt = f"<start_of_turn>user\n{prompt['prompt']}<end_of_turn>\n<start_of_turn>model\n"

        # Tokenize input
        inputs = tokenizer(formatted_prompt, return_tensors="pt")

        # Move to GPU if available
        if torch.cuda.is_available():
            inputs = {k: v.cuda() for k, v in inputs.items()}

        # Generate response
        with torch.no_grad():
            outputs = model.generate(
                **inputs,
                max_new_tokens=200,
                do_sample=True,
                temperature=0.7,
                top_k=50,
                top_p=0.9,
                eos_token_id=tokenizer.eos_token_id,
            )

        # Decode the generated text
        generated_text = tokenizer.decode(outputs[0], skip_special_tokens=True)

        # Extract only the model's response
        if "<start_of_turn>model" in generated_text:
            generated_text = generated_text.split("<start_of_turn>model")[1].strip()

        return {"story": generated_text}
    except Exception as error:
        raise HTTPException(status_code=500, detail=f"Story generation failed: {str(error)}")

if __name__ == "__main__":
    print("\nAccess the API at: http://localhost:8000\n")
    uvicorn.run(app, host="0.0.0.0", port=8000)
>>>>>>> 7a6d40a (Initial project push)
