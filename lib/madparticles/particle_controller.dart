import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:very_good_slide_puzzle/madparticles/particle.dart';
import 'package:very_good_slide_puzzle/puzzle/bloc/puzzle_bloc.dart';

///
class ParticleController extends StatefulWidget {
  ///
  const ParticleController(
    this.size,
    this.numberOfParticles,
    this.state, {
    required Key key,
  }) : super(key: key);

  ///
  final int numberOfParticles;

  ///
  final Size size;

  ///
  final PuzzleState state;

  @override
  State<StatefulWidget> createState() => ParticleControllerState();
}

///
class ParticleControllerState extends State<ParticleController> {
  final List<Particle> _particles = [];

  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_tick);
    _ticker.start();

    final random = Random();

    for (var i = 0; i < widget.numberOfParticles; i++) {
      final initialOffset = Offset(
        random.nextInt(widget.size.width.toInt()).toDouble(),
        random.nextInt(widget.size.height.toInt()).toDouble(),
      );
      final speed = 0.5 + random.nextInt(2).toDouble();
      final direction = random.nextDouble() * 360;
      _particles.add(Particle(initialOffset, speed, direction));
    }
  }

  void _tick(Duration duration) {
    //print(widget.state.puzzle.toString());
    for (final particle in _particles) {
      particle.move(widget.size);
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _ticker
      ..dispose()
      ..stop();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: CustomPaint(
        painter: MadParticlePainter(
          _particles.map((particle) => particle.position).toList(),
        ),
      ),
    );
  }

  ///
  void setTargetPositions(List<Offset> offsets) {
    if (offsets.isEmpty) {
      for (var i = 0; i < _particles.length; i++) {
        _particles[i].targetPosition = null;
      }
      return;
    }

    var ratio = 1.0;
    if (offsets.length > _particles.length) {
      ratio = offsets.length / _particles.length;
      for (var i = 0; i < _particles.length; i++) {
        _particles[i].targetPosition = offsets[(i * ratio).ceil()];
      }
    } else {
      for (var i = 0; i < offsets.length; i++) {
        _particles[i].targetPosition = offsets[i];
      }
    }
  }
}

/// Custom painter for painting simple particles
class MadParticlePainter extends CustomPainter {
  /// Constructor for the painter
  const MadParticlePainter(this.particles);

  /// Offset positions for the particles
  final List<Offset> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final normalPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    //normalPaint.blendMode = BlendMode.colorBurn;
    canvas.drawPoints(PointMode.points, particles, normalPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
