// lib/ui/now_playing/audio_handler.dart

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player;

  // Callback để gọi về Manager khi bấm nút trên thông báo
  Function()? onSkipNext;
  Function()? onSkipPrevious;

  // 🔥 [SỬA Ở ĐÂY] Đưa logic lắng nghe vào thẳng Constructor (Hàm khởi tạo)
  MyAudioHandler(this._player) {
    // Lắng nghe sự kiện từ Player và chuyển đổi sang trạng thái AudioService NGAY LẬP TỨC
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  // ❌ ĐÃ XÓA HÀM init() VÌ KHÔNG CẦN THIẾT NỮA

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
      // Thứ tự nút trên thông báo nhỏ (Android 13+ rất quan trọng cái này)
      androidCompactActionIndices: const [0, 1, 2],
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