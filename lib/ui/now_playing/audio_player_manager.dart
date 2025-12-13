// lib/ui/now_playing/audio_player_manager.dart

import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/foundation.dart';
import '../../data/model/song.dart';
import 'audio_handler.dart';
import '../../data/service/file_manager.dart';

// 🔥 1. CHUYỂN ENUM SANG ĐÂY ĐỂ DÙNG CHUNG (Cắt từ now_playing_page qua)
enum RepeatMode { off, all, one }

class AudioPlayerManager {
  static final AudioPlayerManager _instance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _instance;
  AudioPlayerManager._internal();

  final player = AudioPlayer();
  MyAudioHandler? _audioHandler;
  final songNotifier = BehaviorSubject<Song?>();
  Stream<DurationState>? durationState;
  String? currentSongId;
  Timer? _sleepTimer;
  final isSleepTimerActive = ValueNotifier<bool>(false);
  List<Song> playlist = [];

  // 🔥 2. THÊM 2 BIẾN LƯU TRẠNG THÁI (Mặc định: Tắt)
  bool isShuffle = false;
  RepeatMode loopMode = RepeatMode.off;

  Future<void> init() async {
    _audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(player),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.vanphuc.michaelmusic.channel.audio',
        androidNotificationChannelName: 'Michael Music',
        androidNotificationOngoing: true,
      ),
    );

    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        player.positionStream,
        player.playbackEventStream,
            (position, playbackEvent) => DurationState(
          progress: position,
          buffered: playbackEvent.bufferedPosition,
          total: playbackEvent.duration,
        )).asBroadcastStream();
  }

  void setPlaylist(List<Song> songs, int index) {
    playlist = songs;
    final selectedSong = songs[index];
    final bool isNew = selectedSong.id != currentSongId;
    prepare(song: selectedSong, isNewSong: isNew);
    play();
  }

  Future<void> prepare({required Song song, bool isNewSong = false}) async {
    // Cập nhật UI lần 1 để hiện bài hát ngay
    songNotifier.add(song);

    if (song.id == currentSongId && !isNewSong) return;
    currentSongId = song.id;

    final fileManager = FileManager();

    // 🔥🔥🔥 [SỬA LỖI] TĂNG SỐ LƯỢT NGHE & LƯU VÀO MÁY
    try {
      song.counter = song.counter + 1; // Tăng số đếm
      await fileManager.updateSongInLocal(song); // Lưu vào json
      songNotifier.add(song); // Cập nhật lại UI để hiện số lượt nghe mới ngay lập tức
    } catch (e) {
      print("⚠️ Lỗi cập nhật lượt nghe: $e");
    }
    // 🔥🔥🔥 [HẾT PHẦN SỬA LỖI]

    String sourceToPlay = song.source;
    Uri artUri = Uri.parse(song.image);

    try {
      final localMusicPath = await fileManager.downloadMedia(song.source, song.id, 'source');
      if (localMusicPath != null) sourceToPlay = localMusicPath;
    } catch (e) {
      print("⚠️ Lỗi tải nhạc: $e");
    }

    try {
      final localImagePath = await fileManager.downloadMedia(song.image, song.id, 'image');
      if (localImagePath != null) {
        song.localImagePath = localImagePath;
        artUri = Uri.file(localImagePath);
        fileManager.updateSongInLocal(song);
      }
    } catch (e) {
      print("⚠️ Lỗi tải ảnh: $e");
    }

    final mediaItem = MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      artUri: artUri,
      duration: Duration(seconds: song.duration),
    );

    if (_audioHandler != null) {
      _audioHandler!.mediaItem.add(mediaItem);
    }

    try {
      if (sourceToPlay.startsWith('http')) {
        await player.setAudioSource(AudioSource.uri(
          Uri.parse(sourceToPlay),
          headers: {'ngrok-skip-browser-warning': '1', 'User-Agent': 'MichaelMusicApp'},
          tag: mediaItem,
        ));
      } else {
        await player.setAudioSource(AudioSource.file(sourceToPlay, tag: mediaItem));
      }
    } catch (e) {
      print("❌ Lỗi player: $e");
    }
  }

  void play() => player.play();
  void pause() => player.pause();
  void seek(Duration position) => player.seek(position);
  void stop() => player.stop();
  void dispose() => player.dispose();

  void setSleepTimer(int minutes) {
    cancelSleepTimer();
    isSleepTimerActive.value = true;
    _sleepTimer = Timer(Duration(minutes: minutes), () {
      pause();
      cancelSleepTimer();
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    isSleepTimerActive.value = false;
  }
}

class DurationState {
  const DurationState({this.progress = Duration.zero, this.buffered = Duration.zero, this.total = Duration.zero});
  final Duration progress;
  final Duration buffered;
  final Duration? total;
}