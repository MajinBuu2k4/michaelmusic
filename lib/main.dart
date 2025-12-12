// lib/main.dart
import 'package:flutter/material.dart';
import 'data/service/file_manager.dart';
import 'ui/now_playing/audio_player_manager.dart';

// Import đúng file home.dart (nơi chứa class MusicApp)
import 'ui/home/home.dart';

void main() async {
  // Đảm bảo Flutter khởi động xong các dịch vụ nền
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo trình quản lý file để check nhạc/ảnh
  await FileManager().init();

  // 🔥 KHỞI TẠO AUDIO SERVICE
  await AudioPlayerManager().init();

  // Chạy App với class MusicApp (được định nghĩa bên trong home.dart)
  runApp(const MusicApp());
}