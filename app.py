import json
from fastapi import FastAPI 
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from google import genai
from google.genai import types
import uvicorn

app = FastAPI() 

app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,  
        allow_credentials=True, 
        allow_methods=["*"],  
        allow_headers=["*"], 
        )
   
   
class UserInput(BaseModel):
    mood: str 
    activities: list[str]           
    city: str                      
    meals: list[str]                 
    meal_times: dict[str, str] = None  
    want_room: bool = False 
    room_type: str = "Standard" 
    room_timing: str


@app.get("/")
def index():
    return {"message": "success"}


@app.post("/generate-plan")
async def generate_plan(data: UserInput): 
    activities_str = ", ".join(data.activities)
    meals_str = ", ".join(data.meals)
    meal_times = data.meal_times or {}
    meal_times_str = ", ".join([f"{meal}: {time}" for meal, time in meal_times.items()])

    room_str = ""
    if data.mood.lower() == "romantic" and data.want_room:
        room_type = data.room_type
        room_str = f"Include a {room_type} room for the night."

    client = genai.Client(
        api_key="AIzaSyCLySTr5rIBoz7Kk8PwrEsSYjV2e56aZBc",
    )

    model = "gemini-2.5-flash"

    contents = [
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text=f"""
You are an AI Date Planner. Generate a structured, easy-to-read date plan for a couple in {data.city}.
User preferences:
- Mood: {data.mood}
- Activities: {activities_str}
- Meals: {meals_str} ({meal_times_str})
{room_str}
- Room Timing : {data.room_timing}

Requirements:
1. Suggest exactly 3 activities.
2. Include timings for each activity (morning/evening/night).
3. Include food or drinks recommendations.
4. Include romantic tips for the day.
5. Provide location Name.
6. Output must be valid JSON.
7. Do NOT include any Markdown, code fences, or backticks. Just return plain JSON.
8. Make it concise, engaging, and realistic.

Example format:
{{
  "activity_1": {{"title": "", "timing": "", "details": "", "location name": "","Room Location":""}},
  "activity_2": {{...}},
  "activity_3": {{...}}
}} 
"""),
            ],
        ),
     
    ]

    generate_content_config = types.GenerateContentConfig(
        response_modalities=["TEXT"],
    )

    full_response = ""
    for chunk in client.models.generate_content_stream(
        model=model,
        contents=contents,
        config=generate_content_config,
    ):
        if chunk.text:
            full_response += chunk.text

    try:
        parsed_json = json.loads(full_response)
        return {
            "status": "success",
            "generated_plan": parsed_json
        }
    except json.JSONDecodeError:
        return {
            "status": "error",
            "message": "Invalid JSON format returned from Gemini",
            "raw_output": full_response
        }


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="debug")
