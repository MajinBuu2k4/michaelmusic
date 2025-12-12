// lib/ui/home/mini_player.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/model/song.dart';
import '../now_playing/audio_player_manager.dart';
import '../now_playing/now_playing_page.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimController;
  final _audioPlayerManager = AudioPlayerManager();

  @override
  void initState() {
    super.initState();
    // Animation xoay đĩa
    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    // Lắng nghe trạng thái để xoay/dừng đĩa
    _audioPlayerManager.player.playerStateStream.listen((state) {
      if (state.playing) {
        if (!_imageAnimController.isAnimating) _imageAnimController.repeat();
      } else {
        _imageAnimController.stop();
      }
    });
  }

  @override
  void dispose() {
    _imageAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe bài hát hiện tại
    return StreamBuilder<Song?>(
      stream: _audioPlayerManager.songNotifier,
      builder: (context, snapshot) {
        final song = snapshot.data;

        // Nếu chưa có bài hát nào thì ẩn Mini Player đi
        if (song == null) return const SizedBox.shrink();

        // Nếu có bài thì hiện lên
        return Dismissible(
          key: const Key('mini_player'),
          direction: DismissDirection.down, // Vuốt xuống để ẩn
          onDismissed: (_) {
            _audioPlayerManager.stop();
            _audioPlayerManager.songNotifier.add(null);
          },
          child: Container(
            height: 60, // Chiều cao Mini Player
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, // Màu nền theo giao diện
              border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, -3))
              ],
            ),
            child: InkWell(
              // Bấm vào thì mở Full Player
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NowPlayingPage(
                      // 🔥 SỬA LỖI Ở ĐÂY: Truyền playlist thực tế thay vì list rỗng
                      songs: _audioPlayerManager.playlist,
                      playingSong: song,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  // 1. Đĩa xoay nhỏ
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RotationTransition(
                      turns: _imageAnimController,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundImage: _getArtwork(song),
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ),

                  // 2. Tên bài hát
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // 3. Nút Play/Pause
                  StreamBuilder<PlayerState>(
                    stream: _audioPlayerManager.player.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final playing = playerState?.playing;

                      return IconButton(
                        onPressed: () {
                          if (playing == true) {
                            _audioPlayerManager.pause();
                          } else {
                            _audioPlayerManager.play();
                          }
                        },
                        icon: Icon(
                          playing == true ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          size: 36,
                          color: Colors.deepPurple,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Hàm lấy ảnh
  ImageProvider _getArtwork(Song song) {
    if (song.localImagePath != null && File(song.localImagePath!).existsSync()) {
      return FileImage(File(song.localImagePath!));
    }
    if (song.image.isNotEmpty && !song.image.contains("trống")) {
      return NetworkImage(song.image);
    }
    return const AssetImage('assets/itunes_256.png');
  }
}