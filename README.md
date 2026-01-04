# 🌀 Reset

**Reset** is a high-fidelity, cross-platform recovery and sobriety ecosystem built with Flutter and Firebase. The application is built on a Psychology-First Architecture, utilizing isolated NoSQL data nodes to allow users to manage multiple recoveries independently without logical interference.   

The core of the experience is centered on Cognitive Behavioral Tools (CBT), specifically Manifesto Anchoring and Vulnerability Analysis. By treating every habit as a unique state machine, Reset provides high-precision tracking and real-time temporal calculations.

Supplemental to this core is 'The Anchor'—a context-aware AI strategist powered by Google Gemini. It serves as an on-demand intervention layer, utilizing the user's specific data (streaks, triggers, and motivations) to provide personalized guidance during high-vulnerability moments.

The application features a scalable NoSQL data architecture that treats every habit as an isolated node, allowing for concurrent tracking of multiple dependencies with independent logic states. It leverages GM UI principles and physics-based animations to create a calming, immersive environment.


---

## 🚀 Getting Started
These instructions will get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites
Requirements for building, testing, and deploying the protocol:

* **Flutter SDK v3.0.0+** - UI Framework
* **Firebase Account** - For Auth and Firestore NoSQL Database
* **Google Cloud Console** - To configure OAuth 2.0 IDs for Google Sign-In (Mobile & Desktop)

### Installing

1. **Clone the repository:**
   ```powershell
   git clone [https://github.com/ramosdalrymple-afk/reset_app.git](https://github.com/ramosdalrymple-afk/reset_app.git)
   cd reset

2. **Install Flutter dependencies:**
   ```powershell
   flutter pub get

3. **Firebase Configuration:**
   - Android: Place google-services.json in android/app/.
   - iOS: Place GoogleService-Info.plist in ios/Runner/.
   - Dart: Ensure lib/firebase_options.dart is generated via FlutterFire CLI(make sure to update your specific API_KEY and PROJECT_ID).
   
2. **Run the application:**
   ```powershell
   flutter run

### System Architecture

Reset operates on a Serverless Architecture using Firebase as the backend-as-a-service (BaaS).

 1. Data Modeling (NoSQL) - The database schema is designed for high read-throughput and strict data isolation between habits.
 2. State Management -
    - Provider Pattern: Utilized for dependency injection and state propagation.
    - Optimistic UI: The HabitProvider updates the UI instantly upon user interaction (e.g., resetting a streak), syncing with Firestore in the background to ensure zero-latency responsiveness.
 3. Real-Time Logic Engine -
    - Temporal Differential Calculation: Streak calculations are performed client-side in real-time (DateTime.now().difference(startDate)), ensuring the UI updates to the second without requiring constant database reads.
    - Heuristic Record Keeping: The system automatically compares the "Live Streak" against the "Cached Longest Streak" to display the highest value dynamically.
 4. AI Cognitive Engine (The Anchor) -
    - Global State Injection: The system serializes the entire HabitProvider state into a text summary, allowing the AI to "see" all user habits simultaneously and provide holistic advice (e.g., referencing a smoking habit while discussing a digital detox).
    - Context-Aware Prompting: Utilizes a Generative AI pipeline (Google Gemini 1.5 Flash) that injects real-time habit metadata—including streak duration, user manifesto, and current trigger state—into the model's system instructions.
    - Urge Surfing Protocol: The AI is hard-coded with clinical "Urge Surfing" techniques, moving beyond generic chat to provide structured behavioral intervention during high-risk moments.
    - Intent-Based Navigation (Token Parsing): The LLM is trained to output hidden signals (e.g., <NAV:URGE>, <NAV:CRISIS>). The Flutter frontend intercepts these tokens to render dynamic "Action Chips" that deep-link the user to specific app modules like the Breathing Tool or Emergency Hotline.
### Features

**🧠 Core Recovery Tools**
- The Anchor (AI Peptalk): A 24/7 AI recovery coach that uses the user's personal "Why" (Manifesto) to talk them through cravings using stoic philosophy and CBT.
- Crisis Safety Protocol: A dedicated logic layer within the AI that overrides standard responses upon detecting self-harm keywords. It immediately provides localized emergency resources (e.g., NCMH 1553, 911) and directs the user to the Emergency Screen.
- Multi-Node Tracking: distinct logic containers for different habits (e.g., Substance, Digital hygiene).
- Manifesto Anchoring: cinematic display of the user's "Main Reason" using typographic hierarchy to enforce psychological commitment.
- The Wisdom Jar: An interactive, physics-simulated module using flutter_animate.

**📊 Analytics & Insights**
- Vulnerability Analysis: Tracks relapse triggers to identify high-risk emotional states.
- Mood Graphing: Visualizes emotional stability over time using fl_chart.
- Dual-State Streak Logic: Displays live duration (Days/Hours/Minutes) alongside historical bests.
- Trigger Tracker: A dedicated logging segment for identifying behavioral patterns and intensity of cravings.
- Milestone Projection: Automatically calculates and displays the remaining duration to the next key recovery milestone (e.g., "3 Days left until '2 Weeks' Badge").
  
### 🔄 Workflow
1. Initialization: The user instantiates a new Habit Node via the Settings module or on the onboarding when the user is new.
2. The Pledge: Daily review of the "Manifesto" and "Benefits" cards in the Motivation Tab.
3. The Check-In:
   - Clean: Logs the day, updates the mood graph.
   - Relapse: Triggers the "Hard Reset" protocol. The user selects a trigger (e.g., "Stress"), the startDate is reset to now(), and the streak is archived.
4. Consultation: Interaction with "The Anchor" AI coach for situational strategies or the Wisdom Jar for randomized stoic advice.
5. Journaling: Reflection on triggers and gratitude.

### 🛠 Tech Stack & Dependencies
- Core Framework: Flutter
- Backend: Firebase Auth, Cloud Firestore
- Intelligence: Google Gemini AI API (Generative Language Models)
- Communication: http (RESTful API integration)
- Visualization: fl_chart (Charts), flutter_animate (Complex sequences), confetti (Particle effects), lottie (Vector animations)
- UI Assets: phosphor_flutter (Iconography), google_fonts
  
**Authors**
- Dalrymple Ramos - Lead Developer 
