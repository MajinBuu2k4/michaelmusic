import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/model/song.dart';

class MediaArtwork extends StatelessWidget {
  final Song song;
  final AnimationController animationController;
  final double radius;

  const MediaArtwork({
    super.key,
    required this.song,
    required this.animationController,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: animationController,
      child: Hero(
        tag: song.id,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: _buildArtwork(song),
          ),
        ),
      ),
    );
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