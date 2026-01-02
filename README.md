# 🌀 Reset

**Reset** is a high-performance habit-tracking application engineered with **Flutter** and **Firebase**. The platform features a scalable architecture that enables users to track and manage multiple habits concurrently. By utilizing a structured NoSQL data model, Reset ensures data isolation, real-time synchronization, and a seamless user experience across mobile and desktop environments.

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
   git clone [https://github.com/ramosdalrymple-afk/reset_app.git(https://github.com/ramosdalrymple-afk/reset_app.git)
   cd reset

2. **Install Flutter dependencies:**
   ```powershell
   flutter pub get

3. **Configure Firebase:** Download your google-services.json (for Android) and GoogleService-Info.plist (for iOS) from the Firebase Console and place them in the appropriate directories.
   
4. **Initialize Firebase Options:** Ensure your lib/firebase_options.dart is updated with your specific API_KEY and PROJECT_ID.

**System Architecture**

Reset uses a decentralized data approach. Instead of a single tracking date, every habit is treated as an independent node in a Firestore sub-collection.
 - User Profile: users/{uid}

- Habit Nodes: users/{uid}/habits/{habit_id}

- History Logs: Integrated within each habit node via history maps.

**Features**
- Multi-Habit Tracking: Switch between different habit timers (e.g., No Caffeine, No Gaming) using a horizontal selector.

- Real-time Sync: Data persists across devices instantly via Cloud Firestore.

- Dual-Platform Auth: Custom-built Google Sign-In flow that handles both Mobile and Windows Desktop dependency conflicts.

**Features**
To launch the app on your local machine:


**How it works**
1. Initialization: Navigate to Settings and click "INITIALIZE NEW HABIT" to start a new tracking node.

2. Monitoring: Use the Home Tab selector to switch between active habit tracking.

3. Daily Check-in: Hit "I'M CLEAN" to log a victory for the current 24-hour cycle.

4. Hard Reset: Hit "I RELAPSED" to archive the current streak and start a fresh timer for that specific node.

**Built With**
- Flutter - Cross-platform Framework

- Firebase Auth - Identity Management

- Cloud Firestore - Real-time Data Vault

- Provider - State Management

**Authors**
- Dalrymple Ramos - Lead Developer 
