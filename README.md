<div align="center">

<br/>

```
██╗     ██╗██╗  ██╗
██║     ██║╚██╗██╔╝
██║     ██║ ╚███╔╝ 
██║     ██║ ██╔██╗ 
███████╗██║██╔╝ ██╗
╚══════╝╚═╝╚═╝  ╚═╝
```

### **Light Aurora UI · Multilingual Entertainment & AI Companion**
*Apple Senior UI/UX Designed · Mood-Based Movies, Music & AI Discovery*

<br/>

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Design System](https://img.shields.io/badge/Design-Light%20Aurora%20UI-7C3AED?style=for-the-badge)
![Languages](https://img.shields.io/badge/Languages-42-6C5CE7?style=for-the-badge)
![RTL Support](https://img.shields.io/badge/RTL%20Support-Yes-27AE60?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS%20%7C%20Desktop-lightgrey?style=for-the-badge)

<br/>

> *Built to Apple HIG standards. Designed for everyone, in every language.*

<br/>

</div>

---

## Overview

**LIX** is a next-generation entertainment and AI discovery platform built with Flutter. Inspired by Apple's Senior UI/UX design principles and modern Light Aurora aesthetic, LIX combines mood-driven movie recommendations, streaming audio previews, and natural AI conversation in a clean, highly polished interface.

The app supports **42 languages** (22 Indian regional languages and 20 global languages) with complete **RTL (Right-to-Left) layout support** for Arabic, Urdu, Hebrew, Sindhi, and Kashmiri.

---

## Key Features & Latest Capabilities

### 🎨 1. Light Aurora & Apple HIG Design System
- **Subtle Aurora Gradients**: Soft ambient backgrounds blending violet, rose, sky blue, and mint tints.
- **Glassmorphic Cards**: Pure white card surfaces with crisp hairline borders and soft blurred micro-shadows.
- **Interactive Micro-Animations**: Haptic touch feedback and animated press-scale transitions (`0.92` bounce) on interactive elements.
- **Adaptive Navigation Shell**:
  - **Desktop / Tablet (>700px)**: macOS Sonoma / iPadOS 18 glass sidebar with active gradient squircle badges.
  - **Mobile (<700px)**: Floating glass capsule bottom navigation bar suspended over the screen edge.
- **0 Emojis**: Clean, professional iconography throughout the application.

---

### 🎛️ 2. Vibe Studio (AI Dual Mood Mixer)
- Blend dual emotional states (e.g. *70% Motivated + 30% Happy*) using real-time ratio sliders.
- Generates hybrid movie recommendations and custom music playlists on the fly.
- Powered by free public APIs (iTunes Search API & TMDB API).

---

### 🎯 3. Vibe Matcher (3-Step AI Quiz)
- Interactive 3-card swipe questionnaire:
  1. *Location / Environment* (Home, Commute, Workout, Chill)
  2. *Available Time* (15 min, 1 Hour, Full Evening)
  3. *Target Energy Vibe* (High Energy, Calm, Feel Good, Romantic)
- Instantly computes and reveals the #1 matched movie and song with direct YouTube trailer preview and audio streaming.

---

### 📊 4. Mood Insights & Analytics Dashboard
- Apple Health-style visual dashboard tracking personal vibe activity.
- Active Vibe Streak counter, total interaction metrics, and linear progress charts for mood distributions.
- Personalized Lix AI health & focus recommendations.

---

### 🤖 5. Lix AI Assistant & Conversational Hub
- Apple Intelligence inspired AI conversation screen powered by Groq Llama-3.
- Quick prompt cards for top requests (party songs, sad melodies, artist discographies, mood uplift).
- Context-aware responses in 42 languages.

---

### 🎬 6. Movies & Music Experience
- Real-time mood filtering across movies and music.
- Detailed movie surface with IMDb ratings, quality badges, synopsis, and direct YouTube trailer integration.
- Music player with 30-second audio previews, album artwork rotation, and playlist queues.
- Local Favorites and Watch/Listen History tracking.

---

## Supported Languages

### Indian Regional Languages (22)
| # | Language      | # | Language   | # | Language       |
|---|---------------|---|------------|---|----------------|
| 1 | Hindi         | 9 | Odia       | 17 | Dogri          |
| 2 | Tamil         | 10 | Punjabi    | 18 | Santali        |
| 3 | Telugu        | 11 | Assamese   | 19 | Kashmiri (RTL) |
| 4 | Malayalam     | 12 | Maithili   | 20 | Sindhi (RTL)   |
| 5 | Kannada       | 13 | Sanskrit   | 21 | Manipuri       |
| 6 | Bengali       | 14 | Konkani    | 22 | Bodo           |
| 7 | Gujarati      | 15 | Nepali     |   |                |
| 8 | Marathi       | 16 | Urdu (RTL) |   |                |

### Global Languages (20)
| # | Language     | # | Language   | # | Language      |
|---|--------------|---|------------|---|---------------|
| 1 | English      | 8 | Russian    | 15 | Turkish       |
| 2 | Arabic (RTL) | 9 | Japanese   | 16 | Vietnamese    |
| 3 | French       | 10 | Korean    | 17 | Thai          |
| 4 | Spanish      | 11 | Portuguese | 18 | Hebrew (RTL)  |
| 5 | German       | 12 | Italian    | 19 | Indonesian    |
| 6 | Chinese      | 13 | Dutch      | 20 | Swahili       |
| 7 | Malay        | 14 | Polish     |   |               |

> *RTL — Full Right-to-Left layout support for Arabic, Urdu, Hebrew, Sindhi, and Kashmiri.*

---

## Tech Stack & Architecture

| Layer | Technology |
|---|---|
| **Framework** | Flutter 3.x (Dart 3.x) |
| **Design Tokens** | Light Aurora Design System (`AppTheme`) |
| **Navigation** | `AdaptiveScaffold` (macOS Sidebar & Floating Mobile Capsule) |
| **State & Services** | `ListenableBuilder`, `SharedPreferences`, `AudioPlayers` |
| **Movie Data API** | TMDB API (Free tier) |
| **Music Data API** | iTunes Search API (Free public API, zero-key) |
| **AI Conversational Engine** | Groq Llama-3 API |
| **Video Trailer Integration** | YouTube Player Flutter |

---

## Project Structure

```
lix/
├── lib/
│   ├── main.dart                      # App entry & AuthGate
│   ├── core/
│   │   ├── app_theme.dart             # Light Aurora design system & tokens
│   │   └── responsive.dart            # Breakpoints & centered layout wrapper
│   ├── widgets/
│   │   └── adaptive_scaffold.dart     # Apple glass sidebar & mobile capsule bar
│   ├── screens/
│   │   ├── home_screen.dart           # Primary feed & feature cards
│   │   ├── chat_screen.dart           # Apple Intelligence AI Chat
│   │   ├── movies_screen.dart         # Movie grid & search
│   │   ├── music_screen.dart          # Music list & search
│   │   ├── movie_detail_screen.dart   # Movie details & YouTube trailer
│   │   ├── music_player_screen.dart   # Music player & rotating album art
│   │   ├── profile_screen.dart        # Apple HIG grouped settings
│   │   ├── vibe_studio_screen.dart    # AI Dual Mood Mixer
│   │   ├── vibe_matcher_screen.dart   # 3-Step AI Matcher Quiz
│   │   ├── mood_insights_screen.dart  # Usage & Mood Analytics
│   │   ├── favourites_screen.dart     # Saved movies & songs
│   │   ├── history_screen.dart        # Playback history logs
│   │   └── language_screen.dart       # 42 Language selector
│   └── services/
│       ├── tmdb_service.dart          # TMDB movie API client
│       ├── music_api_service.dart     # iTunes Search API client
│       ├── groq_service.dart          # Groq AI client
│       ├── vibe_mixer_service.dart    # Dual mood blending engine
│       ├── mood_analytics_service.dart# Mood stats & streak tracker
│       ├── favourites_service.dart    # Local favorites manager
│       ├── history_service.dart       # History logger
│       └── language_service.dart      # Translation manager
├── assets/
├── pubspec.yaml
└── README.md
```

---

## Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Chrome / Android Studio / Xcode

### Quick Start
```bash
# Clone the repository
git clone https://github.com/jeswinbenedict/lix.git

# Navigate into the project
cd lix

# Install dependencies
flutter pub get

# Run on Web / Device
flutter run -d chrome --web-port=8080
```

---

## Developer

**Jeswin**  
*Flutter Developer · Tamil Nadu, India*  

LIX is built to make media discovery personal, inclusive, and intuitive.

---

<div align="center">

Built with Flutter &nbsp;|&nbsp; Light Aurora UI &nbsp;|&nbsp; LIX &copy; 2026

</div>
