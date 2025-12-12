import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import '../audio_player_manager.dart';

class MediaProgressBar extends StatelessWidget {
  final AudioPlayerManager audioPlayerManager;

  const MediaProgressBar({
    super.key,
    required this.audioPlayerManager,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DurationState>(
      stream: audioPlayerManager.durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;
        return ProgressBar(
          progress: progress,
          total: total,
          onSeek: audioPlayerManager.seek,
          barHeight: 4,
          thumbRadius: 6,
          thumbGlowRadius: 12,
          timeLabelLocation: TimeLabelLocation.sides,
        );
      },
    );
  }
}