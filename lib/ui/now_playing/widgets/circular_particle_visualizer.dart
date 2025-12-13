import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../data/model/song.dart';

class CircularParticleVisualizer extends StatefulWidget {
  final Song song;
  final double radius; // Bán kính tổng thể

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
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Tạo hiệu ứng chuyển động liên tục
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Tốc độ nhịp
    )..repeat();

    // Khởi tạo 100 hạt ngẫu nhiên
    for (int i = 0; i < 60; i++) {
      _particles.add(Particle(
        angle: _random.nextDouble() * 2 * pi,
        distance: _random.nextDouble(),
        speed: 0.5 + _random.nextDouble() * 0.5,
        size: 2 + _random.nextDouble() * 4,
        color: Colors.primaries[_random.nextInt(Colors.primaries.length)].withOpacity(0.6),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.radius * 2,
      height: widget.radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Lớp vẽ các hạt (Particle Visualizer)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.radius * 2, widget.radius * 2),
                painter: ParticlePainter(
                  particles: _particles,
                  progress: _controller.value,
                  baseRadius: widget.radius - 20, // Bán kính vùng hạt bay
                ),
              );
            },
          ),

          // 2. Ảnh bìa Album (Nằm đè lên trên ở giữa)
          // Có thể thêm hiệu ứng xoay nhẹ hoặc Scale theo nhịp ở đây nếu thích
          ClipOval(
            child: SizedBox(
              width: (widget.radius - 30) * 2, // Nhỏ hơn visualizer một chút
              height: (widget.radius - 30) * 2,
              child: _buildArtwork(widget.song),
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

// Class mô tả một hạt
class Particle {
  double angle; // Góc (vị trí trên vòng tròn)
  double distance; // Khoảng cách từ tâm (0.0 - 1.0)
  double speed;    // Tốc độ di chuyển
  double size;     // Kích thước hạt
  Color color;     // Màu sắc

  Particle({
    required this.angle,
    required this.distance,
    required this.speed,
    required this.size,
    required this.color,
  });
}

// Họa sĩ vẽ hạt
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress; // Giá trị từ 0.0 -> 1.0 (do AnimationController cấp)
  final double baseRadius;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.baseRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var p in particles) {
      // Tính toán chuyển động giả lập
      // Hạt sẽ di chuyển ra/vào theo hàm sin/cos để tạo cảm giác "thở"
      final moveFactor = sin(progress * 2 * pi * p.speed + p.distance * 10);

      // Bán kính hiện tại của hạt (Biến thiên quanh baseRadius)
      final r = baseRadius + (moveFactor * 15); // Dao động biên độ 15px

      // Tọa độ x, y
      final x = center.dx + r * cos(p.angle);
      final y = center.dy + r * sin(p.angle);

      // Vẽ hạt
      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), p.size, paint);

      // Vẽ thêm vệt mờ (Glow effect) cho đẹp
      canvas.drawCircle(
          Offset(x, y),
          p.size * 2,
          Paint()..color = p.color.withOpacity(0.2)
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}