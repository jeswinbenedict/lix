# LIX — Multilingual Entertainment, Personalised for You

<p align="center">
  <img src="assets/screenshots/home.jpg" alt="LIX App" width="220"/>
</p>

<p align="center">
  <strong>Discover movies and music in your language, matched to your mood.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=flat&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Languages-42-6C5CE7?style=flat" />
  <img src="https://img.shields.io/badge/RTL%20Support-Yes-success?style=flat" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=flat" />
  <img src="https://img.shields.io/badge/License-MIT-blue?style=flat" />
</p>

---

## Overview

**LIX** is a multilingual entertainment platform built with Flutter that brings movies and music discovery to users across languages and regions. Whether you are a Tamil speaker in Chennai, an Arabic speaker in Dubai, or an English speaker in London — LIX adapts to your language, your culture, and your current mood.

The app supports **42 languages** including 22 Indian regional languages and 20 global languages, with full **RTL layout support** for Arabic, Urdu, Hebrew, Sindhi, and Kashmiri. At its core, LIX combines personalised mood-based recommendations with a clean, intuitive UI — making entertainment discovery inclusive and accessible.

---

## Key Features

### Multilingual Experience
- Full UI switching across **42 languages**
- **22 Indian languages** including Tamil, Hindi, Telugu, Malayalam, Kannada, Bengali, Gujarati, Marathi, Punjabi, and more
- **20 global languages** including English, Arabic, French, Spanish, German, Japanese, Korean, and more
- **RTL layout support** for Arabic, Urdu, Hebrew, Sindhi, and Kashmiri

### Mood-Based Discovery
- Select your current mood — Happy, Sad, Anxious, Bored, Motivated, Romantic — and receive curated movie and music recommendations tailored to how you feel
- Mood filter persists across the Movies and Music sections for a coherent discovery experience

### Movies
- Browse Indian and international movies
- Discover content through mood-based recommendations
- View movie details including rating, year, genre, quality, and synopsis
- Watch trailers directly via YouTube integration
- Save movies to Favourites
- Track watch history

### Music
- Curated playlists based on mood
- Browse songs across Bollywood, Tamil, Pop, Indian Pop, and more
- 30-second song previews with a mini player
- Persistent playback controls across the app
- Full Now Playing screen with album art, artist info, and playlist position

### Chat with Lix
- Built-in AI assistant named **Lix**
- Ask for movie recommendations, music suggestions, or just have a conversation
- Context-aware responses that understand mood and preference
- Example prompts supported:
  - *"Recommend a good movie for tonight"*
  - *"Tell me about AR Rahman"*
  - *"I just broke up, need comfort"*
  - *"What makes Interstellar so special?"*

### Profile and Personalisation
- User profile management
- Favourites collection
- Watch history
- Notification support
- Dark mode

### Smart Search
- Search across movies and music
- Language and genre-aware results

---

## Supported Languages

### Indian Languages (22)

| # | Language     | # | Language   | # | Language      |
|---|--------------|---|------------|---|---------------|
| 1 | Hindi        | 9 | Odia       | 17 | Dogri         |
| 2 | Tamil        | 10 | Punjabi    | 18 | Santali       |
| 3 | Telugu       | 11 | Assamese   | 19 | Kashmiri (RTL)|
| 4 | Malayalam    | 12 | Maithili   | 20 | Sindhi (RTL)  |
| 5 | Kannada      | 13 | Sanskrit   | 21 | Manipuri      |
| 6 | Bengali      | 14 | Konkani    | 22 | Bodo          |
| 7 | Gujarati     | 15 | Nepali     |   |               |
| 8 | Marathi      | 16 | Urdu (RTL) |   |               |

### Global Languages (20)

| # | Language      | # | Language   | # | Language    |
|---|---------------|---|------------|---|-------------|
| 1 | English       | 8 | Russian    | 15 | Turkish     |
| 2 | Arabic (RTL)  | 9 | Japanese   | 16 | Vietnamese  |
| 3 | French        | 10 | Korean    | 17 | Thai        |
| 4 | Spanish       | 11 | Portuguese | 18 | Hebrew (RTL)|
| 5 | German        | 12 | Italian    | 19 | Indonesian  |
| 6 | Chinese       | 13 | Dutch      | 20 | Swahili     |
| 7 | Malay         | 14 | Polish     |   |             |

> RTL — Right-to-left layout is fully supported for applicable languages.

---

## Screenshots

<table>
  <tr>
    <td align="center">
      <img src="assets/screenshots/home.jpg" width="200"/><br/>
      <sub><b>Home</b></sub>
    </td>
    <td align="center">
      <img src="assets/screenshots/movies.jpg" width="200"/><br/>
      <sub><b>Movies For You</b></sub>
    </td>
    <td align="center">
      <img src="assets/screenshots/movie_detail.jpg" width="200"/><br/>
      <sub><b>Movie Detail</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="assets/screenshots/chat_home.jpg" width="200"/><br/>
      <sub><b>Chat with Lix</b></sub>
    </td>
    <td align="center">
      <img src="assets/screenshots/chat_conversation.jpg" width="200"/><br/>
      <sub><b>Lix in Conversation</b></sub>
    </td>
    <td align="center">
      <img src="assets/screenshots/music.jpg" width="200"/><br/>
      <sub><b>Music For You</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center" colspan="3">
      <img src="assets/screenshots/now_playing.jpg" width="200"/><br/>
      <sub><b>Now Playing</b></sub>
    </td>
  </tr>
</table>

> Place your screenshots in `assets/screenshots/` using the filenames above, or update the paths to match your actual files.

---

## How the App Works

```
1. Launch           →  App loads with language selection
2. Language Pick    →  User selects preferred language (42 options)
3. Home Screen      →  Personalised greeting and mood selector
4. Mood Selection   →  Pick a mood: Happy / Sad / Anxious / Bored / Motivated / Romantic
5. Discovery        →  Movies and music curated to that mood appear
6. Explore          →  Browse, search, view details, watch trailers, preview songs
7. Interact         →  Save to Favourites, track History, chat with Lix
8. Profile          →  Manage account, preferences, and settings
```

### Navigation Structure

The app uses a bottom navigation bar with five primary tabs:

| Tab      | Description                                                  |
|----------|--------------------------------------------------------------|
| Home     | Personalised dashboard with mood picker and curated content  |
| Movies   | Full movies section with mood filters and discovery grid     |
| Chat     | Conversational AI assistant (Lix) for recommendations        |
| Music    | Curated playlists and song browsing by mood                  |
| Profile  | User account, favourites, history, and settings              |

---

## Tech Stack

| Layer            | Technology                                              |
|------------------|---------------------------------------------------------|
| Framework        | [Flutter](https://flutter.dev) (Dart)                  |
| State Management | Configured locally (Riverpod / Bloc / Provider)         |
| Localisation     | Flutter Intl / ARB files (42 languages)                 |
| Navigation       | Flutter Navigator 2.0 / GoRouter                        |
| AI Chat          | Claude API (Anthropic)                                  |
| Media Playback   | Flutter audio player                                    |
| Movie Data       | External movie database API                             |
| Storage          | SharedPreferences / Local DB                            |
| Deep Links       | YouTube (trailer integration)                           |

---

## Project Structure

```
lix/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   └── routes.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   └── utils/
│   ├── features/
│   │   ├── home/
│   │   ├── movies/
│   │   ├── music/
│   │   ├── chat/
│   │   └── profile/
│   ├── l10n/
│   │   └── *.arb              # 42 language files
│   └── shared/
│       ├── widgets/
│       └── models/
├── assets/
│   ├── images/
│   └── screenshots/
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Android Studio or Xcode (for device or emulator)
- A configured physical device or emulator

### Installation

```bash
# Clone the repository
git clone https://github.com/<your-username>/lix.git

# Navigate into the project
cd lix

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# iOS (macOS only)
flutter build ios --release
```

---

## Configuration

> **Important:** This project requires local configuration files for API keys, environment variables, and private settings. These files are intentionally excluded from version control.

Before running the app, create a local configuration file (e.g. `lib/core/constants/env.dart` or `.env`) with your own values:

```dart
// Example — do not commit actual keys
const String apiKey = 'YOUR_API_KEY_HERE';
const String baseUrl = 'YOUR_BASE_URL_HERE';
```

Ensure the following entries are present in your `.gitignore`:

```
*.env
lib/core/constants/secrets.dart
google-services.json
GoogleService-Info.plist
```

Never commit API keys, tokens, or private configuration to version control.

---

## Roadmap

| Status    | Feature                                |
|-----------|----------------------------------------|
| Completed | Mood-based movie recommendations       |
| Completed | Mood-based music playlists             |
| Completed | 42-language localisation               |
| Completed | RTL layout support                     |
| Completed | AI chat assistant (Lix)                |
| Completed | Favourites and watch history           |
| Completed | Dark mode                              |
| Completed | 30-second song preview player          |
| Planned   | Offline mode and content caching       |
| Planned   | User reviews and ratings               |
| Planned   | Social sharing                         |
| Planned   | Push notifications for new releases    |
| Planned   | Watch party and sync feature           |
| Planned   | Advanced search with filters           |

---

## Developer

**Jeswin**  
Flutter Developer · Madurai, Tamil Nadu, India

> LIX was built as a personal project with a focus on inclusive entertainment, multilingual UX, and mood-driven personalisation — bringing together Indian and global content in a single, language-first platform.

---

<p align="center">
  Built with Flutter · Made for everyone, in every language
</p>
