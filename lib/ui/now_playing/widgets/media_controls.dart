import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../audio_player_manager.dart';

class MediaControls extends StatelessWidget {
  final AudioPlayerManager audioPlayerManager;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const MediaControls({
    super.key,
    required this.audioPlayerManager,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.skip_previous, size: 36),
        ),
        StreamBuilder<PlayerState>(
          stream: audioPlayerManager.player.playerStateStream,
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
                onPressed: audioPlayerManager.play,
                icon: const Icon(Icons.play_circle_fill,
                    size: 64, color: Colors.deepPurple),
              );
            } else {
              return IconButton(
                onPressed: audioPlayerManager.pause,
                icon: const Icon(Icons.pause_circle_filled,
                    size: 64, color: Colors.deepPurple),
              );
            }
          },
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.skip_next, size: 36),
        ),
      ],
    );
  }
}