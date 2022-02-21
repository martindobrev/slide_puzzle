import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:very_good_slide_puzzle/madparticles/number_coordinates.dart';
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
  final List<List<Particle>> _tileParticles = [
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    []
  ];
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
        final tileState = widget.state.puzzle.tiles[tile];
        print('Particle position: ${tileState.value}');
        for (var i = 0; i < widget.numberOfParticles; i++) {
          final initialOffset = Offset(
            random.nextInt(widget.size.width.toInt()).toDouble(),
            random.nextInt(widget.size.height.toInt()).toDouble(),
          );
          final speed = 1 + random.nextInt(6).toDouble();
          final direction = random.nextDouble() * 360;
          final particle = Particle(
              initialOffset, speed, direction, widget.state.puzzle.tiles[tile]);
          _tileParticles[tileState.value - 1].add(particle);
          _particles.add(particle);
        }

        final targetPositions = _generateTargetPositions(
          tileState,
          widget.spacing,
        );

        for (var j = 0; j < targetPositions.length; j++) {
          if (_tileParticles[tileState.value - 1].length - 1 >= j) {
            _tileParticles[tileState.value - 1][j].targetPosition =
                targetPositions[j];
          }
        }
      }
    }
  }

  // TODO(maddob): - implement method for generating target positions for tiles
  List<Offset> _generateTargetPositions(
    Tile tile,
    double spacing,
  ) {
    print('Generate target positions for ${tile.toString()}');
    final sizeOfTile = (widget.size.height - widget.spacing * 3) / 4;
    final targetPositions = <Offset>[];
    final offsetX = (tile.currentPosition.x - 1) * sizeOfTile +
        (tile.currentPosition.x - 1) * spacing;
    final offsetY = (tile.currentPosition.y - 1) * sizeOfTile +
        (tile.currentPosition.y - 1) * spacing;
    final offset = Offset(offsetX, offsetY);
    for (var i = 0; i < sizeOfTile.toInt(); i++) {
      targetPositions
        ..add(Offset(offsetX, i.toDouble() + offsetY))
        ..add(Offset(i.toDouble() + offsetX, offsetY))
        ..add(Offset(i.toDouble() + offsetX, offsetY + sizeOfTile))
        ..add(Offset(offsetX + sizeOfTile, i.toDouble() + offsetY));
    }

    final tileDigitCoordinates = digitCoordinates[tile.value - 1];
    for (var j = 0; j < tileDigitCoordinates.length; j++) {
      targetPositions.add(tileDigitCoordinates[j] + offset);
    }

    return _reduceTargetPositions(targetPositions, 3);
  }

  List<Offset> _reduceTargetPositions(List<Offset> positions, int step) {
    final reducedTargetPositions = <Offset>[];
    for (var i = 0; i < positions.length; i++) {
      if (i % step == 0) {
        reducedTargetPositions.add(positions[i]);
      }
    }
    return reducedTargetPositions;
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
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    //normalPaint.blendMode = BlendMode.colorBurn;
    canvas.drawPoints(PointMode.points, particles, normalPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
