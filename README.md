# 📱 Multi-Authentication Flutter App

<p align="center">
  <img src="screenshots/app_demo.gif" width="250" alt="App Demo"/>
</p>

<p align="center">
  <b>A modular Flutter app showcasing multiple authentication systems</b><br>
  Firebase • SQLite • Google • Facebook • Apple Sign-In
</p>

---

## 🚀 Badges

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-Auth-orange?logo=firebase)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)
![License](https://img.shields.io/badge/License-MIT-lightgrey)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)

---

## ✨ Overview

This project demonstrates how to implement **multiple authentication systems** in a clean, modular Flutter architecture.

🔑 Each authentication method:
- Has its **own UI**
- Has its **own logic**
- Is completely **independent**

---

## 🧩 Authentication Methods

### 🔥 Firebase Authentication
- Email & Password  
- Google Sign-In  
- Facebook Login  
- Apple Sign-In  

✔ Online  
✔ Secure  
✔ Scalable  

---

### 💾 SQLite Authentication
- Local Signup/Login  
- Stored on-device  

✔ Offline  
✔ Lightweight  
✔ No external dependency  

---

## 🏗️ Project Structure
lib/
│
├── firebase_login/
│ ├── screens/
│ ├── services/
│ └── widgets/
│
├── sqlite_login/
│ ├── screens/
│ ├── database/
│ └── models/
│
├── common/
│ └── shared/
│
└── main.dart


---

## 🔄 App Flow

App Start
↓
Select Login Method
↓
┌───────────────┬───────────────┐
│ Firebase Flow │ SQLite Flow │
└───────────────┴───────────────┘

---

## 🎥 Demo GIF

> Replace with your own screen recording
screenshots/app_demo.gif


---

## 📸 UI Preview

### 🔥 Firebase Authentication

<p align="center">
  <img src="screenshots/firebase_email_login.png" width="200"/>
  <img src="screenshots/google_signin.png" width="200"/>
  <img src="screenshots/facebook_login.png" width="200"/>
  <img src="screenshots/apple_signin.png" width="200"/>
</p>

---

### 💾 SQLite Authentication

<p align="center">
  <img src="screenshots/sqlite_login.png" width="200"/>
  <img src="screenshots/sqlite_signup.png" width="200"/>
</p>

---

## ⚙️ Setup Guide

### 🔥 Firebase Setup

1. Go to Firebase Console  
2. Create a project  
3. Go to **Authentication → Sign-in method**  
4. Enable:
   - Email/Password  
   - Google  
   - Facebook  
   - Apple  

5. Download:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)

6. Add to your project  

---

### 💾 SQLite Setup

No setup required ✅

---
