# Heal Time

A comprehensive telemedicine and healthcare management Flutter application that seamlessly connects patients with doctors.

## 🚀 Features

### For Patients
* **Find Doctors**: Search and browse available healthcare professionals.
* **Book Appointments**: Schedule consultations based on real-time doctor availability.
* **Medical Records**: Securely upload, view, and manage health documents and prescriptions.
* **End-to-End Encrypted Chat**: Consult securely with your doctors via real-time messaging.
* **Patient Dashboard**: Get an overview of upcoming appointments and health metrics.

### For Doctors
* **Manage Availability**: Set open slots for consultations in real-time.
* **Patient Records**: View patient history and attach diagnosis/prescriptions to completed appointments.
* **Doctor Dashboard**: Keep track of today's schedule at a glance.
* **Direct Messaging**: Communicate seamlessly with assigned patients.

### Architecture & Security
* **Role-Based Access Control**: Secure login/signup system with distinct patient and doctor capabilities.
* **End-to-End Encryption**: Chat messages are encrypted client-side using Diffie-Hellman key exchange (Curve25519) and AES-256-GCM so that the server only ever receives and stores ciphertext.
* **Express & MongoDB Backend**: Robust RESTful API for handling medical records, chats, and scheduling.

## 📱 Tech Stack
* **Frontend**: Flutter / Dart
* **State Management**: Provider
* **Backend**: Node.js, Express, Socket.io (for chat)
* **Database**: MongoDB (Mongoose)
* **Encryption**: `cryptography` package
* **Design**: Custom highly-polished modern UI with dynamic theming.

## 🛠️ Getting Started

### Prerequisites
* Flutter SDK
* Node.js & npm (for backend)
* MongoDB instance 

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd healtime-app
   ```

2. **Backend Setup**
   ```bash
   cd backend
   npm install
   # Start the Express server
   node server.js
   ```

3. **Frontend Setup**
   Ensure the `ApiService.baseUrl` in `lib/utils/api_service.dart` points to your backend IP (e.g., `http://10.X.X.X:5000/api` for local network testing, or `http://10.0.2.2:5000/api` for Android Emulator).
   
   ```bash
   flutter pub get
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

## 🔐 Configuration Highlights
- **Gradle JVM Compatibility**: Configured to use Java 11/17 out-of-the-box (`org.gradle.java.home` in `android/gradle.properties`) to avoid legacy Java 8 sync issues.
- **Local Dev Sync**: The IDE sync is overridden in `/android/gradlew.bat` to guarantee the Android Studio embedded JDK is used.

## 📜 License
This project is licensed under the MIT License.
