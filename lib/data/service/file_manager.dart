// lib/data/service/file_manager.dart

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../model/song.dart';

class FileManager {
  // Singleton
  static final FileManager _instance = FileManager._internal();
  factory FileManager() => _instance;
  FileManager._internal();

  final Dio _dio = Dio();
  final String _fileName = "local_songs.json";

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<void> init() async {
    final file = await _localFile;
    if (!await file.exists()) {
      print("🚀 Lần đầu chạy App, đang copy dữ liệu ra local...");
      try {
        String jsonString = await rootBundle.loadString('assets/michaelsongs.json');
        await file.writeAsString(jsonString);
        print("✅ Đã tạo file local thành công!");
      } catch (e) {
        print("❌ Lỗi khi init file: $e");
      }
    } else {
      print("ℹ️ File local đã tồn tại, dùng luôn.");
    }
  }

  Future<List<Song>> getSongs() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) return [];

      String contents = await file.readAsString();
      final data = jsonDecode(contents);
      final List<dynamic> songList = data['songs'];

      return songList.map((json) => Song.fromJson(json)).toList();
    } catch (e) {
      print("❌ Lỗi đọc file local: $e");
      return [];
    }
  }

  // --- HÀM DOWNLOAD ĐÃ NÂNG CẤP (Thêm Header Ngrok) ---
  Future<String?> downloadMedia(String url, String songId, String type) async {
    if (url.isEmpty || url == "trống cập nhật sau") return null;

    try {
      final dir = await _localPath;
      final saveDir = Directory('$dir/$type');
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      String extension = type == 'source' ? '.wav' : '.png';
      if (url.contains('.mp3')) extension = '.mp3';

      final String savePath = "${saveDir.path}/$songId$extension";
      final File file = File(savePath);

      if (await file.exists()) {
        print("⚡ File đã có sẵn tại: $savePath");
        return savePath;
      }

      print("⬇️ Đang tải $type: $url");

      // 🔥 THÊM HEADER ĐỂ VƯỢT RÀO NGROK
      await _dio.download(
        url,
        savePath,
        options: Options(
          headers: {
            'ngrok-skip-browser-warning': '1', // Chìa khóa qua cổng
            'User-Agent': 'MichaelMusicApp',
          },
        ),
      );

      print("✅ Tải xong: $savePath");
      return savePath;
    } catch (e) {
      print("❌ Lỗi tải file ($type): $e");
      return null;
    }
  }

  Future<void> updateSongInLocal(Song updatedSong) async {
    try {
      List<Song> currentSongs = await getSongs();
      int index = currentSongs.indexWhere((s) => s.id == updatedSong.id);
      if (index != -1) {
        currentSongs[index] = updatedSong;
        final file = await _localFile;
        Map<String, dynamic> newData = {"songs": currentSongs.map((s) => s.toJson()).toList()};
        await file.writeAsString(jsonEncode(newData));
        print("📝 Đã cập nhật file JSON local cho bài: ${updatedSong.title}");
      }
    } catch (e) {
      print("❌ Lỗi cập nhật file local: $e");
    }
  }
}