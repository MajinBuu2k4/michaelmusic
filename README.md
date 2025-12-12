# 🎵 MichaelMusic - App Nghe Nhạc Flutter

> **MichaelMusic** là ứng dụng nghe nhạc cá nhân hóa được xây dựng bằng Flutter. Ứng dụng tập trung vào trải nghiệm mượt mà, hỗ trợ phát nhạc Online/Offline, chạy nền và tính năng hẹn giờ thông minh.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?style=flat&logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android-green?style=flat&logo=android)

## 📸 Hình ảnh Demo (Screenshots)

| Màn hình chính | Trình phát nhạc | Cài đặt & Hẹn giờ |
|:---:|:---:|:---:|
| <img src="assets/screenshots/home.png" width="200"/> | <img src="assets/screenshots/player.png" width="200"/> | <img src="assets/screenshots/settings.png" width="200"/> |
*(Bạn hãy chụp ảnh màn hình app và để vào thư mục `assets/screenshots/` để hiển thị ở đây)*

---

## ✨ Tính năng nổi bật (Key Features)

### 🎧 Trình phát nhạc (Audio Player)
- **Điều khiển cơ bản:** Play, Pause, Next, Previous, Seekbar (tua nhạc).
- **Chế độ phát:**
  - 🔀 **Shuffle:** Trộn bài ngẫu nhiên.
  - 🔁 **Repeat:** Lặp lại danh sách hoặc lặp lại 1 bài (Loop One).
- **Hiệu ứng UI:** Đĩa nhạc xoay (Animation), Hero Animation khi chuyển màn hình.

### 💾 Chế độ Offline thông minh (Hybrid Playback)
- Tự động kiểm tra file trong máy trước khi phát.
- **Auto-Cache:** Khi nghe nhạc online, app tự động tải file MP3 và ảnh bìa về máy.
- Lần nghe sau sẽ phát trực tiếp từ bộ nhớ máy (không tốn 4G/Wifi).

### 📻 Phát nhạc nền (Background Service)
- Tích hợp **Audio Service**: Nhạc vẫn chạy khi tắt màn hình hoặc chuyển app.
- Điều khiển nhạc ngay trên thanh thông báo (Notification Center) và màn hình khóa.

### ⏱️ Tiện ích mở rộng
- **Sleep Timer:** Hẹn giờ tắt nhạc tự động (15p, 30p, 60p hoặc tùy chỉnh theo phút).
- **Dark Mode:** Giao diện tối bảo vệ mắt.
- **Favorites:** Thả tim lưu bài hát yêu thích.

---

## 🛠️ Công nghệ sử dụng (Tech Stack)

Dự án sử dụng các thư viện Flutter hàng đầu để đảm bảo hiệu năng:

| Thư viện | Mục đích |
|:--- |:--- |
| **flutter** | Framework chính |
| **just_audio** | Xử lý phát âm thanh core |
| **audio_service** | Quản lý tác vụ nền, Notification, Lockscreen |
| **dio** | Tải file nhạc/ảnh, xử lý HTTP Request (có Header tùy chỉnh) |
| **path_provider** | Truy cập đường dẫn thư mục hệ thống để lưu file |
| **rxdart** | Xử lý luồng dữ liệu (Stream) cho Seekbar và Player State |
| **audio_video_progress_bar** | Thanh trượt thời gian tùy biến cao |

---

## 📂 Cấu trúc dự án (Project Structure)

Dự án được tổ chức theo mô hình phân lớp gọn gàng:

```text
lib/
├── data/
│   ├── model/          # Định nghĩa Object (Song.dart)
│   ├── repository/     # Xử lý lấy dữ liệu (Repository)
│   └── service/        # Các dịch vụ nền (FileManager.dart xử lý download/cache)
├── ui/
│   ├── home/           # Màn hình danh sách nhạc & MiniPlayer
│   ├── now_playing/    # Màn hình phát nhạc chính
│   │   ├── audio_player_manager.dart # (Core) Logic Singleton quản lý Player
│   │   └── audio_handler.dart        # (Core) Giao tiếp với Notification Android
│   └── settings/       # Màn hình cài đặt & Hẹn giờ
└── main.dart           # Điểm khởi chạy ứng dụng




🚀 Hướng dẫn cài đặt & Chạy (Installation)
Yêu cầu
Flutter SDK (>= 3.0.0)

Android Studio / VS Code

Máy ảo Android hoặc Thiết bị thật

Các bước thực hiện
Clone dự án:

Bash

git clone [https://github.com/username/MichaelMusic.git](https://github.com/username/MichaelMusic.git)
cd MichaelMusic
Cài đặt thư viện:

Bash

flutter pub get
Cấu hình dữ liệu nhạc:

File dữ liệu nằm tại: assets/michaelsongs.json.

Đảm bảo các link nhạc (Source) hoạt động.

Lưu ý: Dự án có xử lý header ngrok-skip-browser-warning để hỗ trợ test server qua Ngrok.

Chạy ứng dụng:

Bash

flutter run
🐛 Các vấn đề đã xử lý (Troubleshooting)
Trong quá trình phát triển, dự án đã giải quyết các vấn đề kỹ thuật phức tạp:

Lỗi "Platform Player already exists":

Giải pháp: Áp dụng Singleton Pattern cho AudioPlayerManager để đảm bảo chỉ có 1 trình phát nhạc duy nhất tồn tại.

Lỗi Crash khi thoát màn hình (AnimationController):

Giải pháp: Kiểm tra mounted và hủy lắng nghe Stream trong dispose().

Stream bị lỗi "Already listened":

Giải pháp: Sử dụng .asBroadcastStream() cho các Stream trạng thái để nhiều màn hình (Home & NowPlaying) cùng lắng nghe được.

🤝 Đóng góp (Contributing)
Mọi đóng góp đều được hoan nghênh! Hãy tạo Pull Request hoặc mở Issue nếu bạn tìm thấy lỗi.

📝 Tác giả
Mai Cồ (Michael) - Developer Phiên bản: 1.0.0 (Michael Music Edition)


---

### Mẹo nhỏ cho bạn:
Để file README này đẹp hơn trên GitHub:
1.  Hãy chụp 3 tấm ảnh màn hình ứng dụng (Home, Player, Settings).
2.  Tạo thư mục `assets/screenshots/` trong dự án.
3.  Lưu ảnh vào đó và đổi tên file ảnh trùng với tên trong file MD (`home.png`, `player.png`...).

File này sẽ giúp bất kỳ ai (kể cả nhà tuyển dụng hay bạn bè) nhìn vào cũng hiểu ngay