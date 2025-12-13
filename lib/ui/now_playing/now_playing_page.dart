// lib/ui/now_playing/now_playing_page.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/model/song.dart';
import '../../data/service/file_manager.dart';
import 'audio_player_manager.dart';

// Import các widget con
import 'widgets/media_artwork.dart';
import 'widgets/media_info.dart';
import 'widgets/media_progress_bar.dart';
import 'widgets/media_controls.dart';
import 'widgets/player_options.dart'; // 🔥 Import widget mới
import 'widgets/circular_particle_visualizer.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({
    super.key,
    required this.songs,
    required this.playingSong,
  });

  final List<Song> songs;
  final Song playingSong;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimController;
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _song;

  StreamSubscription<PlayerState>? _playerStateSubscription;

  // ❌ ĐÃ XÓA: bool _isShuffle, LoopMode _loopMode (Không cần nữa)

  @override
  void initState() {
    super.initState();
    _song = widget.playingSong;
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);

    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    _audioPlayerManager = AudioPlayerManager();
    _audioPlayerManager.prepare(song: _song);

    _playerStateSubscription = _audioPlayerManager.player.playerStateStream.listen((state) {
      if (!mounted) return;

      if (state.processingState == ProcessingState.completed) {
        _imageAnimController.stop();
        _imageAnimController.reset();
        _onSongComplete();
      }
      else if (state.playing) {
        if (!_imageAnimController.isAnimating) {
          _imageAnimController.repeat();
        }
      }
      else {
        if (_imageAnimController.isAnimating) {
          _imageAnimController.stop();
        }
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _imageAnimController.stop();
    _imageAnimController.dispose();
    super.dispose();
  }

  void _onSongComplete() async {
    if (!mounted) return;
    if (_audioPlayerManager.loopMode == RepeatMode.one) {
      await _audioPlayerManager.prepare(song: _song, isNewSong: true);
      _audioPlayerManager.play();
    } else {
      _onNext();
    }
  }

  void _onNext() async {
    _imageAnimController.reset();
    if (widget.songs.isEmpty) return;

    // 🔥 ĐỌC TRỰC TIẾP TỪ MANAGER
    if (_audioPlayerManager.isShuffle) {
      var newIndex = _selectedItemIndex;
      if (widget.songs.length > 1) {
        do {
          newIndex = Random().nextInt(widget.songs.length);
        } while (newIndex == _selectedItemIndex);
      }
      _selectedItemIndex = newIndex;
    } else {
      if (_selectedItemIndex < widget.songs.length - 1) {
        _selectedItemIndex++;
      } else {
        _selectedItemIndex = 0;
      }
    }

    final nextSong = widget.songs[_selectedItemIndex];
    if (mounted) {
      setState(() {
        _song = nextSong;
      });
    }

    await _audioPlayerManager.prepare(song: nextSong);
    _audioPlayerManager.play();
  }

  void _onPrevious() async {
    _imageAnimController.reset();
    if (widget.songs.isEmpty) return;

    // 🔥 ĐỌC TRỰC TIẾP TỪ MANAGER
    if (_audioPlayerManager.isShuffle) {
      _selectedItemIndex = Random().nextInt(widget.songs.length);
    } else {
      if (_selectedItemIndex > 0) {
        _selectedItemIndex--;
      } else {
        _selectedItemIndex = widget.songs.length - 1;
      }
    }

    final prevSong = widget.songs[_selectedItemIndex];
    if (mounted) {
      setState(() {
        _song = prevSong;
      });
    }

    await _audioPlayerManager.prepare(song: prevSong);
    _audioPlayerManager.play();
  }

  void _onToggleFavorite() async {
    setState(() {
      _song.favorite = _song.favorite == "true" ? "false" : "true";
    });
    await FileManager().updateSongInLocal(_song);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Now Playing"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
        // 🔥 GỌI WIDGET MỚI Ở ĐÂY
        actions: const [
          PlayerOptions(),
          SizedBox(width: 8), // Chừa chút lề phải
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_song.album,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            // Code cũ:
            //MediaArtwork(
              //song: _song,
              //animationController: _imageAnimController,
              //radius: radius,
            //),
            // Code MỚI (Thay thế đoạn trên bằng đoạn này):
            CircularParticleVisualizer(
              song: _song,
              radius: radius, // Giữ nguyên bán kính cũ
            ),
            const SizedBox(height: 24),
            MediaInfo(
              song: _song,
              onToggleFavorite: _onToggleFavorite,
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: MediaProgressBar(
                audioPlayerManager: _audioPlayerManager,
              ),
            ),
            const SizedBox(height: 32),
            MediaControls(
              audioPlayerManager: _audioPlayerManager,
              onNext: _onNext,
              onPrevious: _onPrevious,
            ),
          ],
        ),
      ),
    );
  }
}