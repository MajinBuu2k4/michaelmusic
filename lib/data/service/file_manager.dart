// lib/data/service/file_manager.dart

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart'; // 🔥 Thêm thư viện này để dùng PublishSubject
import '../model/song.dart';

class FileManager {
  static final FileManager _instance = FileManager._internal();
  factory FileManager() => _instance;
  FileManager._internal();

  final Dio _dio = Dio();
  final String _fileName = "local_songs.json";

  // 🔥 Tín hiệu thông báo download xong (Stream)
  final downloadCompleteNotifier = PublishSubject<String>();

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
      try {
        String jsonString = await rootBundle.loadString('assets/michaelsongs.json');
        await file.writeAsString(jsonString);
      } catch (e) {
        print("❌ Lỗi khi init file: $e");
      }
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
        return savePath;
      }

      print("⬇️ Đang tải $type: $url");

      await _dio.download(
        url,
        savePath,
        options: Options(
          headers: {
            'ngrok-skip-browser-warning': '1',
            'User-Agent': 'MichaelMusicApp',
          },
        ),
      );

      print("✅ Tải xong: $savePath");

      // 🔥 BẮN TÍN HIỆU: Báo cho cả App biết là tải xong rồi nhé!
      if (type == 'source') {
        downloadCompleteNotifier.add(songId);
      }

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
      }
    } catch (e) {
      print("❌ Lỗi cập nhật file local: $e");
    }
  }
}