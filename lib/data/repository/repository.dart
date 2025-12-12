// lib/data/repository/repository.dart

import '../model/song.dart';
import '../service/file_manager.dart';

// Interface giữ nguyên để không làm lỗi các file khác
abstract class Repository {
  Future<List<Song>> loadData();
}

// Implementation mới: Dùng FileManager
class DefaultRepository implements Repository {
  final _fileManager = FileManager();

  @override
  Future<List<Song>> loadData() async {
    // 1. Bảo ông quản gia chuẩn bị dữ liệu (copy từ assets nếu cần)
    await _fileManager.init();

    // 2. Lấy danh sách bài hát từ file local (đã có biến counter, localPath...)
    List<Song> songs = await _fileManager.getSongs();

    // 3. Nếu danh sách rỗng (lỗi gì đó), trả về rỗng
    if (songs.isEmpty) {
      return [];
    }

    return songs;
  }
}