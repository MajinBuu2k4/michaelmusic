// lib/ui/now_playing/widgets/player_options.dart

import 'package:flutter/material.dart';
import '../audio_player_manager.dart';

class PlayerOptions extends StatefulWidget {
  const PlayerOptions({super.key});

  @override
  State<PlayerOptions> createState() => _PlayerOptionsState();
}

class _PlayerOptionsState extends State<PlayerOptions> {
  final _audioPlayerManager = AudioPlayerManager();

  // Biến local để rebuild UI nút bấm
  late bool _isShuffle;
  late RepeatMode _loopMode;

  @override
  void initState() {
    super.initState();
    _isShuffle = _audioPlayerManager.isShuffle;
    _loopMode = _audioPlayerManager.loopMode;
  }

  void _onToggleShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
      _audioPlayerManager.isShuffle = _isShuffle;
    });
    _showToast(_isShuffle ? "Bật trộn bài 🔀" : "Tắt trộn bài");
  }

  void _onToggleLoop() {
    setState(() {
      // 🔥 Sửa các case thành RepeatMode
      switch (_loopMode) {
        case RepeatMode.off:
          _loopMode = RepeatMode.all;
          _showToast("Lặp danh sách 🔁");
          break;
        case RepeatMode.all:
          _loopMode = RepeatMode.one;
          _showToast("Lặp 1 bài 🔂");
          break;
        case RepeatMode.one:
          _loopMode = RepeatMode.off;
          _showToast("Tắt lặp");
          break;
      }
      _audioPlayerManager.loopMode = _loopMode;
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

  Icon _getLoopIcon() {
    // 🔥 Sửa các case thành RepeatMode
    switch (_loopMode) {
      case RepeatMode.off:
        return const Icon(Icons.repeat);
      case RepeatMode.all:
        return const Icon(Icons.repeat, color: Colors.deepPurple);
      case RepeatMode.one:
        return const Icon(Icons.repeat_one, color: Colors.deepPurple);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: _onToggleShuffle,
          icon: Icon(Icons.shuffle,
              color: _isShuffle ? Colors.deepPurple : Colors.grey),
        ),
        IconButton(
          onPressed: _onToggleLoop,
          icon: _getLoopIcon(),
          color: _loopMode == RepeatMode.off ? Colors.grey : Colors.deepPurple,
        ),
      ],
    );
  }
}