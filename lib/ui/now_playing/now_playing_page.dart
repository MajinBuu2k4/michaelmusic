// lib/ui/now_playing/now_playing_page.dart

import 'dart:async'; // Cần import thư viện này
import 'dart:io';
import 'dart:math';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/model/song.dart';
import '../../data/service/file_manager.dart';
import 'audio_player_manager.dart';

enum LoopMode { off, all, one }

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

  // 🔥 Biến này để quản lý việc lắng nghe Player, tránh crash khi thoát màn hình
  StreamSubscription<PlayerState>? _playerStateSubscription;

  bool _isShuffle = false;
  LoopMode _loopMode = LoopMode.off;

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

    // 🔥 FIX LỖI CRASH: Gán vào biến Subscription
    _playerStateSubscription = _audioPlayerManager.player.playerStateStream.listen((state) {
      // 🔥 QUAN TRỌNG: Kiểm tra mounted. Nếu màn hình đã đóng thì không làm gì cả
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
    // 🔥 FIX LỖI CRASH: Hủy lắng nghe trước khi hủy controller
    _playerStateSubscription?.cancel();

    _imageAnimController.stop();
    _imageAnimController.dispose();
    super.dispose();
  }

  void _onSongComplete() async {
    if (!mounted) return;
    if (_loopMode == LoopMode.one) {
      await _audioPlayerManager.prepare(song: _song, isNewSong: true);
      _audioPlayerManager.play();
    } else {
      _onNext();
    }
  }

  void _onNext() async {
    _imageAnimController.reset();

    if (_isShuffle) {
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

    if (_isShuffle) {
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

  void _onToggleLoop() {
    setState(() {
      switch (_loopMode) {
        case LoopMode.off:
          _loopMode = LoopMode.all;
          _showToast("Lặp danh sách 🔁");
          break;
        case LoopMode.all:
          _loopMode = LoopMode.one;
          _showToast("Lặp 1 bài 🔂");
          break;
        case LoopMode.one:
          _loopMode = LoopMode.off;
          _showToast("Tắt lặp");
          break;
      }
    });
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
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
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isShuffle = !_isShuffle;
              });
              _showToast(_isShuffle ? "Bật trộn bài 🔀" : "Tắt trộn bài");
            },
            icon: Icon(Icons.shuffle,
                color: _isShuffle ? Colors.deepPurple : Colors.grey),
          ),
          IconButton(
            onPressed: _onToggleLoop,
            icon: _getLoopIcon(),
            color: _loopMode == LoopMode.off ? Colors.grey : Colors.deepPurple,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_song.album,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),

            RotationTransition(
              turns: _imageAnimController,
              child: Hero(
                tag: _song.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: SizedBox(
                    width: radius * 2,
                    height: radius * 2,
                    child: _buildArtwork(_song),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _onToggleFavorite,
                  icon: Icon(
                    _song.favorite == "true"
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _song.favorite == "true" ? Colors.red : Colors.grey,
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _song.title,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _song.artist,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(CupertinoIcons.headphones,
                                size: 14, color: Colors.blueGrey),
                            const SizedBox(width: 4),
                            Text(
                              "${_song.counter} lượt nghe",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: StreamBuilder<DurationState>(
                stream: _audioPlayerManager.durationState,
                builder: (context, snapshot) {
                  final durationState = snapshot.data;
                  final progress = durationState?.progress ?? Duration.zero;
                  final total = durationState?.total ?? Duration.zero;
                  return ProgressBar(
                    progress: progress,
                    total: total,
                    onSeek: _audioPlayerManager.seek,
                    barHeight: 4,
                    thumbRadius: 6,
                    thumbGlowRadius: 12,
                    timeLabelLocation: TimeLabelLocation.sides,
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _onPrevious,
                  icon: const Icon(Icons.skip_previous, size: 36),
                ),
                StreamBuilder<PlayerState>(
                  stream: _audioPlayerManager.player.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing;

                    if (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering) {
                      return const SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(),
                      );
                    } else if (playing != true) {
                      return IconButton(
                        onPressed: _audioPlayerManager.play,
                        icon: const Icon(Icons.play_circle_fill,
                            size: 64, color: Colors.deepPurple),
                      );
                    } else {
                      return IconButton(
                        onPressed: _audioPlayerManager.pause,
                        icon: const Icon(Icons.pause_circle_filled,
                            size: 64, color: Colors.deepPurple),
                      );
                    }
                  },
                ),
                IconButton(
                  onPressed: _onNext,
                  icon: const Icon(Icons.skip_next, size: 36),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Icon _getLoopIcon() {
    switch (_loopMode) {
      case LoopMode.off:
        return const Icon(Icons.repeat);
      case LoopMode.all:
        return const Icon(Icons.repeat);
      case LoopMode.one:
        return const Icon(Icons.repeat_one);
    }
  }

  Widget _buildArtwork(Song song) {
    if (song.localImagePath != null && song.localImagePath!.isNotEmpty) {
      return Image.file(
        File(song.localImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/itunes_256.png', fit: BoxFit.cover),
      );
    }
    if (song.image.isNotEmpty && !song.image.contains("trống")) {
      return Image.network(
        song.image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/itunes_256.png', fit: BoxFit.cover),
      );
    }
    return Image.asset(
      'assets/itunes_256.png',
      fit: BoxFit.cover,
    );
  }
}