// lib/ui/home/tab_download.dart

import 'dart:io';
import 'dart:async'; // Cần import cái này để dùng StreamSubscription
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/model/song.dart';
import '../../data/service/file_manager.dart';
import 'song_list_view.dart';

class DownloadTab extends StatefulWidget {
  const DownloadTab({super.key});

  @override
  State<DownloadTab> createState() => _DownloadTabState();
}

class _DownloadTabState extends State<DownloadTab> {
  List<Song> downloadedSongs = [];
  bool isLoading = true;

  // Biến để quản lý việc lắng nghe sự kiện
  StreamSubscription? _downloadSubscription;

  @override
  void initState() {
    super.initState();
    _loadDownloadedSongs();

    // 🔥 PHƯƠNG ÁN 1: AUTO LOAD REAL-TIME
    // Lắng nghe tín hiệu từ FileManager. Hễ có file tải xong là reload list ngay.
    _downloadSubscription = FileManager().downloadCompleteNotifier.listen((_) {
      print("🔄 Nhận tín hiệu tải xong, đang reload danh sách Download...");
      _loadDownloadedSongs();
    });
  }

  @override
  void dispose() {
    // Hủy lắng nghe khi thoát màn hình để tránh lỗi
    _downloadSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadDownloadedSongs() async {
    // Không set isLoading = true ở đây nữa để tránh nháy màn hình khi auto load
    // setState(() => isLoading = true);

    final allSongs = await FileManager().getSongs();
    final directory = await getApplicationDocumentsDirectory();
    final sourceDir = Directory('${directory.path}/source');

    List<Song> tempDownloaded = [];

    if (await sourceDir.exists()) {
      for (var song in allSongs) {
        final fileMp3 = File('${sourceDir.path}/${song.id}.mp3');
        final fileWav = File('${sourceDir.path}/${song.id}.wav');

        if (await fileMp3.exists()) {
          song.localAudioPath = fileMp3.path;
          tempDownloaded.add(song);
        } else if (await fileWav.exists()) {
          song.localAudioPath = fileWav.path;
          tempDownloaded.add(song);
        }
      }
    }

    if (mounted) {
      setState(() {
        downloadedSongs = tempDownloaded;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đã Tải Xuống"),
        centerTitle: true,
        // 🔥 PHƯƠNG ÁN 2: NÚT RELOAD THỦ CÔNG
        actions: [
          IconButton(
            onPressed: () {
              setState(() => isLoading = true); // Hiện loading khi bấm tay
              _loadDownloadedSongs();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : downloadedSongs.isEmpty
          ? _buildEmptyState()
          : SongListView(songs: downloadedSongs, onRefresh: _loadDownloadedSongs),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.cloud_download_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text("Chưa có bài hát nào được tải xuống"),
        ],
      ),
    );
  }
}