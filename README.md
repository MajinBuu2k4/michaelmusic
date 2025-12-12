# 🎵 MichaelMusic — Ứng dụng Nghe Nhạc Flutter

**MichaelMusic** là ứng dụng nghe nhạc cá nhân hóa được xây dựng bằng Flutter, tập trung vào trải nghiệm mượt mà, hỗ trợ Online/Offline, phát nền và hẹn giờ thông minh.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=flat\&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?style=flat\&logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android-green?style=flat\&logo=android)

---

## 📸 Demo Screenshots

|                         Home                         |                         Player                         |                         Settings                         |
| :--------------------------------------------------: | :----------------------------------------------------: | :------------------------------------------------------: |
| <img src="assets/screenshots/home.png" width="200"/> | <img src="assets/screenshots/player.png" width="200"/> | <img src="assets/screenshots/settings.png" width="200"/> |

> Đặt ảnh vào thư mục `assets/screenshots/` để hiển thị đúng.

---

## ✨ Tính năng nổi bật

### 🎧 Trình phát nhạc

* Play / Pause / Next / Previous
* Seekbar điều khiển thời gian
* Chế độ:

  * 🔀 Shuffle
  * 🔁 Repeat / Repeat One
* Hiệu ứng UI: Hero Animation, đĩa nhạc xoay

### 💾 Chế độ Offline thông minh

* Tự kiểm tra file nội bộ trước khi phát
* **Auto-Cache**: Ghi MP3 + ảnh bìa khi nghe Online
* Lần sau phát trực tiếp từ bộ nhớ (không tốn mạng)

### 📻 Background Playback

* Tích hợp **audio_service**
* Điều khiển trên Notification và màn hình khóa

### ⏱️ Tiện ích khác

* Sleep Timer: 15 / 30 / 60 phút hoặc tùy chỉnh
* Dark Mode
* Favorite Songs

---

## 🛠️ Công nghệ sử dụng

| Thư viện                 | Mục đích                  |
| :----------------------- | :------------------------ |
| flutter                  | Framework chính           |
| just_audio               | Core audio playback       |
| audio_service            | Background + Notification |
| dio                      | Download / HTTP request   |
| path_provider            | Truy cập thư mục hệ thống |
| rxdart                   | Stream & state handling   |
| audio_video_progress_bar | ProgressBar tùy biến      |

---

## 📂 Cấu trúc dự án

```text
lib/
├── data/
│   ├── model/          # Song model
│   ├── repository/     # Data sources
│   └── service/        # FileManager, cache, downloads
├── ui/
│   ├── home/           # Home + MiniPlayer
│   ├── now_playing/    # Player screen
│   │   ├── audio_player_manager.dart
│   │   └── audio_handler.dart
│   └── settings/       # Cài đặt + Hẹn giờ
└── main.dart           # Entry point
```

---

## 🚀 Cài đặt & Chạy ứng dụng

### Yêu cầu

* Flutter SDK ≥ 3.0.0
* Android Studio / VS Code
* Thiết bị thật hoặc máy ảo Android

### Các bước

#### 1. Clone dự án

```bash
git clone https://github.com/username/MichaelMusic.git
cd MichaelMusic
```

#### 2. Cài đặt thư viện

```bash
flutter pub get
```

#### 3. Cấu hình dữ liệu nhạc

* File: `assets/michaelsongs.json`
* Kiểm tra các link nhạc hoạt động
* Dự án có hỗ trợ header *ngrok-skip-browser-warning* (dùng khi test qua Ngrok)

#### 4. Chạy ứng dụng

```bash
flutter run
```

---

## 🐛 Troubleshooting (Các lỗi phổ biến)

### ❗ “Platform Player already exists”

* Dùng **Singleton** cho `AudioPlayerManager` để tránh tạo nhiều instance.

### ❗ Crash khi thoát màn hình (AnimationController)

* Kiểm tra `mounted`
* Hủy mọi listener trong `dispose()`

### ❗ Stream bị lỗi “Already listened”

* Dùng `.asBroadcastStream()` để nhiều màn hình cùng nghe được.

---

## 🤝 Đóng góp

Mọi đóng góp đều được chào đón!
Hãy tạo Pull Request hoặc mở Issue.

---

## 📝 Tác giả

**Mai Cồ (Michael)**
Phiên bản: **1.0.0 – Michael Music Edition**

---

### 🔧 Gợi ý để README đẹp hơn

1. Chụp ảnh Home – Player – Settings
2. Lưu tại: `assets/screenshots/`
3. Đặt tên: `home.png`, `player.png`, `settings.png`
