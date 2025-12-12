// lib/ui/now_playing/audio_handler.dart

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player;

  // Callback để gọi về Manager khi bấm nút trên thông báo
  Function()? onSkipNext;
  Function()? onSkipPrevious;

  MyAudioHandler(this._player);

  Future<void> init() async {
    // Lắng nghe sự kiện từ Player và chuyển đổi sang trạng thái AudioService
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  // --- HÀM BIẾN ĐỔI TRẠNG THÁI (QUAN TRỌNG) ---
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
      },
      androidCompactActionIndices: const [0, 1, 2], // Thứ tự nút trên thông báo nhỏ (Prev, Play/Pause, Next)
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() async {
    if (onSkipNext != null) onSkipNext!();
  }

  @override
  Future<void> skipToPrevious() async {
    if (onSkipPrevious != null) onSkipPrevious!();
  }
}