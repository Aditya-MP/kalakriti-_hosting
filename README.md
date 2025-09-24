

# Kalakriti - AI Marketplace Assistant for Artisans 🎨

Transforming Local Artisans with AI-Powered Storytelling

*"Every craft, a Legacy" - Bridging tradition with technology*

---

## 🎯 The Challenge
Across India, thousands of artisans carry forward centuries-old traditions. But limited digital access and shifting consumer trends threaten both their livelihood and our cultural heritage.

### Our Mission
Preserve cultural heritage while ensuring fair value & sustainable livelihood for artisans

---

## ✨ The Kalakriti Solution
An AI-powered marketplace assistant that connects artisans (Kalakaars) with art lovers (Rasiks)

### For Artisans (Kalakaars):
- 🎙️ Voice-First Setup - "Talk, don't type" product uploads
- 🤖 AI Story Engine - Transform descriptions into compelling narratives
- 💰 Market Value Ranging - AI-powered fair pricing based on trends
- 🌐 Multi-Platform Reach - Share creations across marketplaces instantly
- 🏪 Digital Showrooms - Beautiful galleries, not just product listings

### For Buyers (Rasiks):
- 🎨 Art Gallery Experience - Discover crafts through stories, not just listings
- 🔍 Curated Discovery - Find authentic handmade treasures
- 🌍 Multi-Platform Access - Buy through preferred channels
- 📖 Story-Driven Shopping - Understand the heart behind each craft

---

## 🚀 Key Features

| Feature                | Description                                   | Impact                              |
|-----------------------|-----------------------------------------------|-------------------------------------|
| Digital Showroom      | Beautiful portfolio showcasing artisan's journey | Professional online presence        |
| AI Voice Assistant    | Voice-to-story conversion in regional languages | Easy digital onboarding             |
| Market Value AI       | Smart pricing based on market trends            | Fair compensation for artisans      |
| Multi-Platform Upload | One-click sharing to Instagram, Amazon, etc.    | Expanded market reach               |
| Story-Driven Listings | Products presented as narrative experiences     | Emotional buyer connection          |

---

## 🏗️ Technical Architecture

### Frontend (Flutter)
- **Cross-Platform:** Single codebase for Android, iOS, Web, Desktop
- **Firebase Integration:** Real-time database and authentication
- **Voice Features:** Speech-to-text for easy product uploads

### Backend & AI (Google Cloud)
- **FastAPI Server:** Python backend for AI processing
- **Gemini AI Models:** Story generation and pricing suggestions
- **Vertex AI:** Advanced search and recommendations
- **Firebase Functions:** Serverless architecture

### Database & Deployment
- **Cloud Firestore, Firebase Storage:** Data and media storage
- **Firebase Hosting:** Web app deployment
- **GitHub Actions:** CI/CD automation

### AI/ML
- **Gemini, Vertex AI, Hugging Face:** AI-powered story and pricing

---

## Cloud Infrastructure Workflow

Artisan Voice Input → AI Story Generation → Digital Showroom → Multi-Platform Distribution
		 ↓                      ↓                      ↓                  ↓
	Speech API           Gemini AI            Firebase Hosting    Social Media + E-commerce

---

## 📱 How It Works

### For Artisans:
1. **Sign Up** → Create digital identity
2. **Voice Describe** → Speak about your craft
3. **AI Magic** → Automatic story + pricing
4. **Publish** → Share across platforms

### For Buyers:
1. **Browse Gallery** → Discover authentic crafts
2. **Read Stories** → Understand artisan journey
3. **Choose Platform** → Buy through preferred channel
4. **Support Artisans** → Fair price, direct impact

---

## 🎨 Unique Selling Points

❤️ **Humanizes E-commerce**
Shopping feels like visiting an art gallery
Every product has a story, not just specifications

🎯 **Artisan-Centric Design**
Voice-first for easy digital adoption
AI handles the complex, artisans focus on creating

🌍 **Cultural Preservation**
Documents and promotes traditional crafts
Connects next generation with heritage

🔮 **Future Vision**
**Community Building:** Live workshops & craft demonstrations, artisan networking and collaboration
**AI Enhancement:** Regional language voice translation, AR/VR virtual artisan workspace tours
**Sustainability:** Premium features for advanced analytics, government/NGO partnerships for artisan welfare

---

## 🛠️ Technology Stack

- **Frontend:** Flutter, Dart, Firebase SDK
- **Backend:** Python, FastAPI, Google Cloud Functions
- **AI/ML:** Gemini, Vertex AI, Hugging Face
- **Database:** Cloud Firestore, Firebase Storage
- **Deployment:** Firebase Hosting, GitHub Actions

---

## 👥 Team Nova Vertex
Adithya M P (Team Lead) & talented developers building tech for social impact

---

## 🌟 Impact Metrics

- **Digital Empowerment:** Artisans gain online presence without technical skills
- **Fair Pricing:** AI ensures market-aligned compensation
- **Cultural Preservation:** Traditional crafts reach global audiences
- **Economic Growth:** Sustainable livelihoods for artisan communities

---

<div align="center">
🚀 Ready to Transform Artisan Commerce?
Join us in preserving heritage through innovation

"Where every craft has a story, and every artisan has a voice"

Thank YOU
</div>

# Kalakriti 2.0

## Overview

Kalakriti 2.0 is a cross-platform digital platform for artisans and crafters to instantly create, manage, and showcase their work in digital showrooms. The project leverages Flutter for the frontend and Python (FastAPI) for backend AI-powered storytelling and marketing content generation.

---

## Project Structure

```
kalakriti-2.0/
├── backend/
│   ├── main.py                # FastAPI backend for AI story generation
│   ├── requirements.txt       # Python dependencies
│   └── .env                   # Environment variables (not committed)
├── lib/
│   ├── screens/
│   │   ├── showroom_setup.dart    # Instant digital showroom feature for artisans
│   │   ├── pre_post_overview.dart # Product overview and marketing strategy
│   │   └── ...                    # Other UI screens
│   ├── services/
│   │   ├── marketing_strategy_service.dart # Calls backend for AI-powered strategy
│   │   ├── firestore_service.dart          # Firestore integration
│   │   └── ...                             # Other services
│   ├── models/
│   │   └── marketing_strategy.dart         # Data models
│   └── main.dart                          # Flutter app entry point
├── assets/                                # Images, fonts, etc.
├── pubspec.yaml                           # Flutter dependencies
├── .env                                   # Flutter environment variables (not committed)
├── .gitignore                             # Ensures secrets are not committed
└── README.md                              # Project documentation
```

---

## Technical Architecture & Technologies Used

### Frontend (Flutter)
- **Flutter SDK (Dart):** Cross-platform UI for Web, Android, iOS, Desktop.
- **Key Packages:**
	- `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_storage`: Firebase integration for auth, database, and media.
	- `speech_to_text`: Speech recognition for instant showroom setup.
	- `flutter_tts`: Text-to-speech for accessibility.
	- `image_picker`: Media upload.
	- `http`: REST API calls to backend.
	- `flutter_dotenv`: Secure environment variable management.
	- `share_plus`, `permission_handler`, etc.: Utility plugins.

### Backend (Python)
- **FastAPI:** REST API server for AI-powered features.
- **Hugging Face Transformers:** Loads and serves the `google/gemma-3-270m-it` model for story and marketing content generation.
- **Python Packages:** fastapi, transformers, torch, python-dotenv, uvicorn.

### Cloud & DevOps
- **Firebase:**
	- **Authentication:** User login/session management.
	- **Firestore:** Stores user, product, and showroom data.
	- **Storage:** Stores images, videos, PDFs.
	- **Hosting:** Web app deployment.
- **Git & GitHub:** Version control and remote repository.
- **GitHub Actions:** CI/CD automation (if configured).
- **Environment Variables (.env):** Secure management of secrets and API keys.

### Other
- **VS Code:** Common IDE for Flutter and Python development.
- **Markdown/JSON:** For documentation and configuration.

---

## Key Features

- **Instant Digital Showroom:**  
	Artisans can instantly create and manage a digital showroom for their artwork/products (`showroom_setup.dart`).
- **AI-Powered Story Generation:**  
	Backend uses Hugging Face’s `google/gemma-3-270m-it` model to generate creative stories or marketing content for products and showrooms.
- **Speech-to-Text:**  
	Artisans can dictate product descriptions or showroom details by voice.
- **User Authentication & Profiles:**  
	Secure login and user management via Firebase Auth.
- **Media Upload & Management:**  
	Upload images, videos, and PDFs to Firebase Storage.
- **Secure Secret Management:**  
	All sensitive keys/tokens managed via `.env` and never committed to the repo.

---

## How It Works (Workflow)

1. **User logs in** via Firebase Auth.
2. **Artisan sets up a showroom** using the Flutter app, with speech-to-text for easy input.
3. **Media uploads** are stored in Firebase Storage.
4. **Product/showroom data** is saved in Firestore.
5. **Marketing strategy/story generation** requests are sent to the FastAPI backend.
6. **Backend loads the Gemini model** and generates a story or strategy, returning it to the app.
7. **Explore page** displays products and showrooms with AI-generated content.

---

## Security

- All secrets (API keys, tokens) are stored in `.env` files and are **never committed** to the repository.
- `.gitignore` ensures sensitive files are excluded from version control.

---

## Getting Started

1. **Clone the repo:**  
	 `git clone https://github.com/Aditya-MP/kalakriti-_hosting.git`
2. **Set up `.env` files** for both Flutter and Python backend.
3. **Install dependencies:**  
	 - Flutter: `flutter pub get`
	 - Python: `pip install -r backend/requirements.txt`
4. **Run the backend:**  
	 `uvicorn backend.main:app --reload`
5. **Run the Flutter app:**  
	 `flutter run -d chrome` (for web)

---
