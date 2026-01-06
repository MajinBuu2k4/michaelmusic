import 'dart:async'; // Để dùng StreamSubscription
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // Import để bắt trạng thái Playing/Paused
import '../../../data/model/song.dart';
import '../audio_player_manager.dart'; // Gọi ông quản lý nhạc

class CircularParticleVisualizer extends StatefulWidget {
  final Song song;
  final double radius;

  const CircularParticleVisualizer({
    super.key,
    required this.song,
    required this.radius,
  });

  @override
  State<CircularParticleVisualizer> createState() => _CircularParticleVisualizerState();
}

class _CircularParticleVisualizerState extends State<CircularParticleVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Biến để quản lý lắng nghe nhạc
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // 🔥 LOGIC MỚI: Tự động Bật/Tắt theo trạng thái nhạc
    final player = AudioPlayerManager().player;

    _playerStateSubscription = player.playerStateStream.listen((state) {
      // Nếu nhạc đang chạy (playing) và chưa kết thúc (completed)
      if (state.playing && state.processingState != ProcessingState.completed) {
        if (!_controller.isAnimating) {
          _controller.repeat(); // Cho quẩy
        }
      } else {
        // Nhạc tắt hoặc đang buffer -> Dừng hình ngay
        if (_controller.isAnimating) {
          _controller.stop(); // Stop ngay tại chỗ
        }
      }
    });
  }

  @override
  void dispose() {
    // Nhớ hủy lắng nghe để tránh lỗi
    _playerStateSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double artSize = (widget.radius - 20) * 2;

    return SizedBox(
      width: widget.radius * 2,
      height: widget.radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Sóng nhạc Neon
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.radius * 2, widget.radius * 2),
                painter: NeonSpectrumPainter(
                  animationValue: _controller.value, // Giá trị dừng thì sóng cũng dừng
                  radius: widget.radius - 10,
                ),
              );
            },
          ),

          // 2. Ảnh bìa Album (Xoay theo nhạc)
          RotationTransition(
            turns: _controller, // Controller dừng thì ảnh cũng ngừng xoay
            child: Container(
              width: artSize,
              height: artSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: ClipOval(
                child: _buildArtwork(widget.song),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(Song song) {
    if (song.localImagePath != null && song.localImagePath!.isNotEmpty) {
      return Image.file(
        File(song.localImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset('assets/itunes_256.png', fit: BoxFit.cover),
      );
    }
    if (song.image.isNotEmpty && !song.image.contains("trống")) {
      return Image.network(
        song.image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset('assets/itunes_256.png', fit: BoxFit.cover),
      );
    }
    return Image.asset(
      'assets/itunes_256.png',
      fit: BoxFit.cover,
    );
  }
}

// 🔥 HỌA SĨ VẼ SÓNG NEON (Giữ nguyên độ chất chơi)
class NeonSpectrumPainter extends CustomPainter {
  final double animationValue;
  final double radius;

  NeonSpectrumPainter({
    required this.animationValue,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double barCount = 100;
    final double angleStep = (2 * pi) / barCount;

    // Gradient xoay theo animationValue
    final Gradient gradient = SweepGradient(
      startAngle: 0.0,
      endAngle: 2 * pi,
      colors: const [
        Colors.cyanAccent,
        Colors.purpleAccent,
        Colors.redAccent,
        Colors.orangeAccent,
        Colors.yellowAccent,
        Colors.cyanAccent,
      ],
      transform: GradientRotation(animationValue * 2 * pi),
    );

    final Paint paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius + 50))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final Paint glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.cyanAccent.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawCircle(center, radius, glowPaint);

    for (int i = 0; i < barCount; i++) {
      double angle = i * angleStep;

      // Fake FFT: Nếu animationValue không đổi (nhạc tắt) -> t không đổi -> sóng đứng yên
      double t = animationValue * 8 * pi;

      double wave1 = sin(angle * 10 + t);
      double wave2 = cos(angle * 25 - t * 2);
      double wave3 = sin(angle * 5 + t * 0.5);

      double magnitude = (wave1 + wave2 + wave3).abs() / 3;
      double barHeight = 10 + (magnitude * 40);

      double pulse = 1.0 + (sin(t) * 0.05);

      double startRadius = radius * pulse;
      double endRadius = (radius + barHeight) * pulse;

      Offset p1 = Offset(
        center.dx + startRadius * cos(angle),
        center.dy + startRadius * sin(angle),
      );

      Offset p2 = Offset(
        center.dx + endRadius * cos(angle),
        center.dy + endRadius * sin(angle),
      );

      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}