
# Dating App – AI Date Planner

**Description**
A Flutter-based mobile application that helps couples plan their perfect day together. The app generates a personalized date plan based on user preferences such as mood, activities, meals, and more. Beautiful UI with romantic themes and fonts for a delightful experience.

---

## Features

* **AI-Powered Date Planner:** Suggests 3 activities for the day based on user input.
* **Customizable Preferences:** Users can choose mood, activities, meals, meal timings, city, and whether they want a room for the night.
* **Food & Drink Recommendations:** Suggests what to eat/drink during the day.
* **Romantic Tips:** Adds extra tips to make the date memorable.
* **Beautiful UI:** Uses romantic fonts (Great Vibes) and background images for immersive experience.
* **Responsive Layout:** Works on different screen sizes with proper spacing and alignment.

---

## Screenshots
<img width="460" height="784" alt="Screenshot 2025-10-21 202132" src="https://github.com/user-attachments/assets/4a5bdd6b-1ec1-41a2-aee2-0c5e10e797a3" />
<img width="441" height="777" alt="Screenshot 2025-10-21 202139" src="https://github.com/user-attachments/assets/e36bb605-4345-4d68-ab24-ca9fa19071fd" />
<img width="418" height="773" alt="Screenshot 2025-10-21 202455" src="https://github.com/user-attachments/assets/a9beae94-1ee7-434d-983e-4f1abac9a147" />
<img width="433" height="501" alt="Screenshot 2025-10-21 202440" src="https://github.com/user-attachments/assets/adfa2999-ac62-4fd4-a7ae-21113801e924" />





---

## Installation

1. **Clone the repository:**

```bash
git clone https://github.com/bnaveenbharathi/AI-DATING-PLANER-APP.git
cd AI-DATING-PLANER-APP
```

2. **Install Flutter dependencies:**

```bash
flutter pub get
```

3. **Run the app:**

```bash
flutter run
```

---

## Usage

1. Open the app.
2. Enter your preferences:

   * Mood (e.g., Romantic, Fun, Casual)
   * Activities you want to do
   * Meals & meal timings
   * City
   * Room requirement (if romantic mood)
3. Tap **Start Planning ❤️**.
4. The AI generates a personalized 3-activity date plan with tips and locations.

---


## Tech Stack

### Backend

* **Python**
* **FastAPI** – For building the API to generate date plans.
* **Uvicorn** – ASGI server for running FastAPI.
* **Pydantic** – For data validation and serialization.
* **Google GenAI** – AI model integration for generating date plans.

**Installation (Backend):**

1. Create and activate a virtual environment:

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies from `requirements.txt`:

```bash
pip install -r requirements.txt
```

3. Run the API server:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

---

### Frontend

* **Flutter** – For building the mobile app.
* **Google Fonts** – For custom romantic fonts (`Great Vibes`).
* **Material Design** – For UI components.

**Installation (Frontend):**

1. Install Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install).
2. Navigate to the project folder and get dependencies:


```bash
cd APP
```

```bash
flutter pub get
```

3. Run the app on an emulator or connected device:

```bash
flutter run
```

---

### AI Integration

* **Google GenAI API** – Generates structured, personalized date plans based on user input such as mood, activities, meals, city, and room preferences.

---

