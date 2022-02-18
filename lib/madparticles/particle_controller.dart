import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:very_good_slide_puzzle/madparticles/particle.dart';
import 'package:very_good_slide_puzzle/models/tile.dart';
import 'package:very_good_slide_puzzle/puzzle/bloc/puzzle_bloc.dart';

///
class ParticleController extends StatefulWidget {
  ///
  const ParticleController(
    this.size,
    this.numberOfParticles,
    this.state,
    this.spacing, {
    required Key key,
  }) : super(key: key);

  ///
  final int numberOfParticles;

  ///
  final Size size;

  ///
  final PuzzleState state;

  final double spacing;

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

    for (var tile = 0; tile < widget.state.puzzle.tiles.length; tile++) {
      if (!widget.state.puzzle.tiles[tile].isWhitespace) {
        for (var i = 0; i < widget.numberOfParticles; i++) {
          final initialOffset = Offset(
            random.nextInt(widget.size.width.toInt()).toDouble(),
            random.nextInt(widget.size.height.toInt()).toDouble(),
          );
          final speed = 5 + random.nextInt(10).toDouble();
          final direction = random.nextDouble() * 360;
          final particle = Particle(
              initialOffset, speed, direction, widget.state.puzzle.tiles[tile]);
          particle.targetPosition =
              _generateTargetPosition(widget.state.puzzle.tiles[tile]);
          _particles.add(particle);
        }
      }
    }
  }

  // TODO(maddob): - implement method for generating target positions for tiles
  List<Offset> _generateTargetPositions(
    Tile tile,
    double spacing,
  ) {
    //
    return [];
  }

  void _tick(Duration duration) {
    //print(widget.state.puzzle.toString());
    for (final particle in _particles) {
      particle.move(widget.size);
    }
    setState(() {});
  }

  Offset _generateTargetPosition(Tile tile) {
    final size = widget.size.height / 4;
    final r = Random();
    final xSpacing = tile.currentPosition.x * widget.spacing;
    final ySpacing = tile.currentPosition.y * widget.spacing;
    return Offset(
        size * (tile.currentPosition.x - 1) +
            r.nextInt(size.toInt()) +
            xSpacing,
        size * (tile.currentPosition.y - 1) +
            r.nextInt(size.toInt()) +
            ySpacing);
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
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    //normalPaint.blendMode = BlendMode.colorBurn;
    canvas.drawPoints(PointMode.points, particles, normalPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
