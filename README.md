# 🌀 Reset

**Reset** is a high-fidelity, cross-platform recovery/soberity application developed with Flutter and Firebase. Unlike generic habit trackers, Reset utilizes a psychology-first architecture, integrating cognitive behavioral tools (CBT) such as vulnerability analysis, gratitude journaling, and motivational anchoring directly into the user experience.

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

### Features

**🧠 Core Recovery Tools**
- Multi-Node Tracking: distinct logic containers for different habits (e.g., Substance, Digital hygiene).
- Manifesto Anchoring: cinematic display of the user's "Main Reason" using typographic hierarchy to enforce psychological commitment.
- The Wisdom Jar: An interactive, physics-simulated module using flutter_animate.

**📊 Analytics & Insights**
- Vulnerability Analysis: Tracks relapse triggers to identify high-risk emotional states.
- Mood Graphing: Visualizes emotional stability over time using fl_chart.
- Dual-State Streak Logic: Displays live duration (Days/Hours/Minutes) alongside historical bests.

### 🔄 Workflow
1. Initialization: The user instantiates a new Habit Node via the Settings module or on the onboarding when the user is new.
2. The Pledge: Daily review of the "Manifesto" and "Benefits" cards in the Motivation Tab.
3. The Check-In:
   - Clean: Logs the day, updates the mood graph.
   - Relapse: Triggers the "Hard Reset" protocol. The user selects a trigger (e.g., "Stress"), the startDate is reset to now(), and the streak is archived.
4. Consultation: Interaction with the Wisdom Jar for randomized stoic/recovery advice.
5. Journaling

### 🛠 Tech Stack & Dependencies
- Core Framework: Flutter
- Backend: Firebase Auth, Cloud Firestore
- Visualization: fl_chart (Charts), flutter_animate (Complex sequences), confetti (Particle effects), lottie (Vector animations)
- UI Assets: phosphor_flutter (Iconography), google_fonts
  
**Authors**
- Dalrymple Ramos - Lead Developer 
