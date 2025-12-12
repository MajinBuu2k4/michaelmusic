// lib/ui/home/song_list_view.dart

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/model/song.dart';
import '../now_playing/now_playing_page.dart';
import '../now_playing/audio_player_manager.dart';

class SongListView extends StatelessWidget {
  final List<Song> songs;
  final VoidCallback? onRefresh;

  const SongListView({
    super.key,
    required this.songs,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return const Center(child: Text("Không có dữ liệu"));
    }

    return ListView.separated(
      // 🔥 Tăng padding bottom lên một chút để chắc chắn item cuối không bị MiniPlayer che
      padding: const EdgeInsets.only(bottom: 160),
      itemCount: songs.length,
      separatorBuilder: (_, __) => const Divider(indent: 64, height: 1),
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

          // Ảnh bìa
          leading: Hero(
            // 🔥 SỬA LỖI Ở ĐÂY: Dùng chính xác song.id làm tag để khớp với trang NowPlaying
            tag: song.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 50,
                height: 50,
                child: _buildArtwork(song),
              ),
            ),
          ),

          // Tên bài hát
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),

          // Tên ca sĩ + Lượt nghe
          subtitle: Row(
            children: [
              Flexible(
                child: Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(CupertinoIcons.headphones, size: 12, color: Colors.grey),
              Text(" ${song.counter}", style: const TextStyle(fontSize: 12)),
            ],
          ),

          // Sự kiện bấm vào bài hát
          onTap: () => _playSong(context, song),
        );
      },
    );
  }

  Widget _buildArtwork(Song song) {
    if (song.localImagePath != null && File(song.localImagePath!).existsSync()) {
      return Image.file(
        File(song.localImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset('assets/itunes_256.png'),
      );
    }
    if (song.image.startsWith("http")) {
      return FadeInImage.assetNetwork(
        placeholder: 'assets/itunes_256.png',
        image: song.image,
        fit: BoxFit.cover,
        imageErrorBuilder: (_, __, ___) => Image.asset('assets/itunes_256.png'),
      );
    }
    return Image.asset('assets/itunes_256.png', fit: BoxFit.cover);
  }

  void _playSong(BuildContext context, Song song) {
    int index = songs.indexOf(song);
    AudioPlayerManager().setPlaylist(songs, index);

    Navigator.push(
      context,
      PageRouteBuilder(
        // Tăng thời gian transition lên một chút để nhìn rõ hiệu ứng Hero
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => NowPlayingPage(songs: songs, playingSong: song),
        transitionsBuilder: (_, animation, __, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          // Sử dụng curve chuẩn của iOS/Material cho mượt
          const curve = Curves.fastOutSlowIn;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    ).then((_) {
      if (onRefresh != null) onRefresh!();
    });
  }
}