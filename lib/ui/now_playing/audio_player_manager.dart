// lib/ui/now_playing/audio_player_manager.dart

import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/foundation.dart';
import '../../data/model/song.dart';
import 'audio_handler.dart';
import '../../data/service/file_manager.dart';

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

  // --- 🔥 LOGIC ĐÃ SỬA: CHECK TRÙNG BÀI ---
  void setPlaylist(List<Song> songs, int index) {
    final selectedSong = songs[index];

    // Kiểm tra: Nếu bài được chọn (selectedSong) khác với bài đang phát (currentSongId)
    // thì mới đánh dấu là bài mới (isNew = true) để load lại từ đầu.
    // Ngược lại, nếu trùng ID, isNew = false -> giữ nguyên tiến độ đang phát.
    final bool isNew = selectedSong.id != currentSongId;

    prepare(song: selectedSong, isNewSong: isNew);
    play();
  }
  // ----------------------------------------

  Future<void> prepare({required Song song, bool isNewSong = false}) async {
    songNotifier.add(song);

    // Nếu bài này đang load rồi thì thôi (Giữ nguyên trạng thái đang phát)
    if (song.id == currentSongId && !isNewSong) return;

    currentSongId = song.id;

    final fileManager = FileManager();
    String sourceToPlay = song.source;
    Uri artUri = Uri.parse(song.image);

    // Check Nhạc
    try {
      final localMusicPath = await fileManager.downloadMedia(song.source, song.id, 'source');
      if (localMusicPath != null) {
        sourceToPlay = localMusicPath;
      }
    } catch (e) {
      print("⚠️ Lỗi tải nhạc: $e");
    }

    // Check Ảnh
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
        await player.setAudioSource(AudioSource.file(
          sourceToPlay,
          tag: mediaItem,
        ));
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