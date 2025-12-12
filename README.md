# 🎵 MichaelMusic — Ứng dụng Nghe Nhạc Flutter

**MichaelMusic** là ứng dụng nghe nhạc cá nhân hóa được xây dựng bằng Flutter, tập trung vào trải nghiệm mượt mà, hỗ trợ Online/Offline tự động, phát nền (background playback) và các tiện ích hẹn giờ thông minh.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?style=flat&logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android-green?style=flat&logo=android)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

---

## 📸 Demo Giao Diện

|          Màn Hình Chính (Home)           |            Trình Phát Nhạc (Player)            |              Cài Đặt (Settings)              |
| :--------------------------------------: | :--------------------------------------------: | :------------------------------------------: |
| <img src="assets/screenshots/home.png" width="200"/> | <img src="assets/screenshots/player.png" width="200"/> | <img src="assets/screenshots/settings.png" width="200"/> |

> *Lưu ý: Hãy thêm ảnh chụp màn hình vào thư mục `assets/screenshots/` để hiển thị demo.*

---

## ✨ Tính năng nổi bật

### 🎧 Trình phát nhạc chuyên nghiệp (Audio Player)
* **Điều khiển đầy đủ**: Play, Pause, Next, Previous.
* **Thanh tiến trình (Seekbar)**: Kéo tua mượt mà với `audio_video_progress_bar`.
* **Chế độ phát**:
  * 🔀 **Shuffle**: Trộn bài hát ngẫu nhiên.
  * 🔁 **Loop**: Lặp danh sách (Repeat All) hoặc lặp 1 bài (Repeat One).
* **Hiệu ứng Visual**: Đĩa nhạc xoay (Rotation Animation), Hero Animation khi chuyển màn hình.

### 💾 Chế độ Offline thông minh (Smart Cache)
* **Cơ chế tự động**: Khi nghe nhạc Online, ứng dụng tự động tải file MP3 và ảnh bìa về máy.
* **Ưu tiên Local**: Lần sau phát bài hát đó, ứng dụng sẽ lấy file từ bộ nhớ máy thay vì tốn dung lượng mạng.
* **Tab Download**: Quản lý danh sách các bài hát đã tải xuống thành công.

### 📻 Phát nền & Thông báo (Background Playback)
* Tích hợp **audio_service** giúp nhạc vẫn phát khi tắt màn hình hoặc dùng ứng dụng khác.
* Điều khiển nhạc (Play/Pause/Next/Prev) ngay trên thanh thông báo (Notification Center) và màn hình khóa.

### ⏱️ Tiện ích mở rộng
* **Hẹn giờ tắt nhạc (Sleep Timer)**: Tự động dừng nhạc sau 15, 30, 60 phút hoặc thời gian tùy chỉnh.
* **Mini Player**: Thanh phát nhạc thu nhỏ ở dưới cùng màn hình giúp điều khiển nhanh khi đang lướt danh sách.
* **Yêu thích**: Đánh dấu bài hát yêu thích (Heart icon).
* **Dark Mode**: Chuyển đổi giao diện Sáng/Tối.

---

## 🛠️ Công nghệ sử dụng

Dự án được xây dựng trên **Flutter** với các thư viện lõi:

| Thư viện | Phiên bản | Mục đích sử dụng |
| :--- | :--- | :--- |
| **flutter** | Stable | Framework phát triển ứng dụng đa nền tảng. |
| **just_audio** | `^0.9.x` | Xử lý phát âm thanh cốt lõi, playlist, buffering. |
| **audio_service** | `^0.18.x` | Xử lý phát nhạc dưới nền (Background task), Notification control. |
| **audio_session** | `^0.1.x` | Quản lý phiên âm thanh (tự dừng khi có cuộc gọi đến). |
| **dio** | `^5.4.x` | Tải file nhạc/ảnh (HTTP Client mạnh mẽ). |
| **path_provider** | `^2.1.x` | Truy cập đường dẫn thư mục hệ thống để lưu file cache. |
| **rxdart** | `^0.27.x` | Quản lý State bằng Streams (BehaviorSubject, combineLatest). |
| **permission_handler**| `^12.0.x` | Xin quyền truy cập bộ nhớ, thông báo. |
| **audio_video_progress_bar** | `^2.0.x` | Thanh seekbar hiển thị thời gian và buffer. |

---

## 📂 Cấu trúc dự án

Code được tổ chức theo kiến trúc phân tách rõ ràng (Clean Architecture cơ bản):

```text
lib/
├── data/
│   ├── model/          # Song model (song.dart) - Định nghĩa dữ liệu bài hát
│   ├── repository/     # Repository pattern - Xử lý nguồn dữ liệu
│   └── service/        # Các dịch vụ nền:
│       └── file_manager.dart  # Quản lý tải file, đọc/ghi JSON local
├── ui/
│   ├── home/           # Màn hình chính
│   │   ├── home.dart          # Tab Home
│   │   ├── tab_download.dart  # Tab bài hát đã tải
│   │   ├── song_list_view.dart # Widget hiển thị danh sách bài hát
│   │   └── mini_player.dart   # Widget trình phát nhạc thu nhỏ
│   ├── now_playing/    # Màn hình phát nhạc chi tiết
│   │   ├── audio_player_manager.dart # Logic xử lý Audio Player (Singleton)
│   │   ├── audio_handler.dart        # Cấu hình AudioService
│   │   └── widgets/                  # Các widget con (Artwork, Controls, ProgressBar...)
│   └── settings/       # Màn hình cài đặt
│       ├── settings.dart      # UI Cài đặt & Hẹn giờ
│       └── theme_manager.dart # Quản lý Dark/Light mode
└── main.dart           # Điểm khởi chạy ứng dụng

---
🚀 Hướng dẫn cài đặt & Chạy ứng dụng
1. Yêu cầu môi trường
Flutter SDK: 3.3.0 trở lên.

Java JDK: 11 hoặc 17.

Android Studio hoặc VS Code.

2. Clone dự án
Bash

git clone [https://github.com/majinbuu2k4/michaelmusic.git](https://github.com/majinbuu2k4/michaelmusic.git)
cd michaelmusic
3. Cài đặt thư viện
Bash

flutter pub get
4. Cấu hình quyền (Android)
File AndroidManifest.xml đã được cấu hình sẵn các quyền cần thiết:

INTERNET: Để tải nhạc.

WAKE_LOCK, FOREGROUND_SERVICE: Để phát nhạc dưới nền.

READ/WRITE_EXTERNAL_STORAGE: Để lưu cache (với Android cũ).

5. Dữ liệu nhạc
File cấu hình nhạc nằm tại assets/michaelsongs.json.

Lưu ý: Hiện tại trong code mẫu đang sử dụng link từ ngrok. Nếu link chết hoặc server đóng, vui lòng cập nhật lại URL trong file JSON này sang link MP3 trực tiếp khác để test.

6. Chạy ứng dụng
Bash

flutter run
🐛 Khắc phục sự cố thường gặp (Troubleshooting)
Lỗi không tải được nhạc (Dio Error)
Kiểm tra kết nối mạng.

Kiểm tra URL trong michaelsongs.json. Do sử dụng Ngrok miễn phí, link có thể bị hết hạn.

Trong FileManager, code đã thêm header 'ngrok-skip-browser-warning': '1' để vượt qua trang cảnh báo của Ngrok.

Lỗi cấp quyền Android 13+
Từ Android 13 (API 33), quyền đọc file âm thanh là READ_MEDIA_AUDIO. Ứng dụng sử dụng permission_handler để tự động yêu cầu quyền phù hợp. Nếu bị từ chối, hãy vào Cài đặt ứng dụng để cấp quyền thủ công.

Lỗi xung đột phiên bản Kotlin/Gradle
Dự án đang dùng Gradle 8.14 và Kotlin 1.9.x (hoặc mới hơn). Đảm bảo Android Studio của bạn đã cập nhật SDK phù hợp.

🤝 Đóng góp (Contributing)
Mọi đóng góp đều được hoan nghênh! Nếu bạn tìm thấy lỗi hoặc muốn thêm tính năng mới:

Fork dự án.

Tạo nhánh tính năng (git checkout -b feature/AmazingFeature).

Commit thay đổi (git commit -m 'Add some AmazingFeature').

Push lên nhánh (git push origin feature/AmazingFeature).

Tạo Pull Request.

📝 Tác giả
Mai Cồ (Van Phuc)

Ứng dụng được phát triển với niềm đam mê âm nhạc và lập trình Flutter