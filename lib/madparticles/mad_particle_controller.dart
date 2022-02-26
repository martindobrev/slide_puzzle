import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_slide_puzzle/madparticles/number_coordinates.dart';
import 'package:very_good_slide_puzzle/madparticles/particle.dart';
import 'package:very_good_slide_puzzle/models/tile.dart';
import 'package:very_good_slide_puzzle/puzzle/bloc/puzzle_bloc.dart';

///
/// Particle Controller
///
/// Initializes the particles and orders them to represent the
/// puzzle state. Each tile consist of multiple particles. Each particle
/// moves freely inside the board, when it receives a target position, it
/// is moved towards this position. Moving tiles is done by changing target
/// positions of the particles.
///
///
class MadParticleController extends StatefulWidget {
  ///
  const MadParticleController(
    this.size,
    this.numberOfParticles,
    this.state,
    this.spacing, {
    required Key key,
  }) : super(key: key);

  ///
  final int numberOfParticles;

  /// Size of the puzzle board
  final Size size;

  /// State of the puzzle
  final PuzzleState state;

  /// spacing between the tiles
  final double spacing;

  @override
  State<StatefulWidget> createState() => MadParticleControllerState();
}

/// State of the particle controller
class MadParticleControllerState extends State<MadParticleController> {
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
  late Timer _secondsTimer;
  int _secondsCounter = 0;
  final GlobalKey _painterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_tick);
    _ticker.start();
    const oneSecondDuration = Duration(seconds: 1);

    _initialiseParticlePositions(widget.state.puzzle.tiles);
    _secondsTimer = Timer.periodic(oneSecondDuration, (timer) {
      _secondsCounter++;
      final currentDuration = Duration(seconds: _secondsCounter);
      final minutes = currentDuration.inMinutes;
      final seconds = currentDuration.inSeconds;
      print('$minutes:$seconds');
    });
  }

  void _initialiseParticlePositions(List<Tile> tiles) {
    final random = Random();
    for (var tile = 0; tile < tiles.length; tile++) {
      if (!widget.state.puzzle.tiles[tile].isWhitespace) {
        final tileState = widget.state.puzzle.tiles[tile];
        final targetPositions = _generateTargetPositions(
          tileState,
          widget.spacing,
        );
        for (var i = 0; i < targetPositions.length; i++) {
          final initialOffset = Offset(
            random.nextInt(widget.size.width.toInt()).toDouble(),
            random.nextInt(widget.size.height.toInt()).toDouble(),
          );
          final speed = 4 + random.nextInt(5).toDouble();
          final direction = random.nextDouble() * 360;
          final particle = Particle(
            initialOffset,
            speed,
            direction,
            widget.state.puzzle.tiles[tile],
            easingFunctionList[random.nextInt(easingFunctionList.length)],
            random.nextInt(50) + 50,
          );
          _tileParticles[tileState.value - 1].add(particle);
          particle.targetPosition = targetPositions[i];
          _particles.add(particle);
        }
      }
    }

    // for (final i = 0, i < 100; i++) {
    //   initialOffset
    // }
  }

  List<Offset> _generateTargetPositions(
    Tile tile,
    double spacing,
  ) {
    final sizeOfTile = (widget.size.height - widget.spacing * 3) / 4;
    final targetPositions = <Offset>[];
    final offsetX = (tile.currentPosition.x - 1) * sizeOfTile +
        (tile.currentPosition.x - 1) * widget.spacing;
    final offsetY = (tile.currentPosition.y - 1) * sizeOfTile +
        (tile.currentPosition.y - 1) * widget.spacing;
    final offset = Offset(offsetX, offsetY);
    for (var i = 0; i < sizeOfTile.toInt(); i++) {
      targetPositions
        ..add(Offset(offsetX, i.toDouble() + offsetY))
        ..add(Offset(i.toDouble() + offsetX, offsetY))
        ..add(Offset(i.toDouble() + offsetX, offsetY + sizeOfTile))
        ..add(Offset(offsetX + sizeOfTile, i.toDouble() + offsetY));
    }

    final tileDigitCoordinates = digitCoordinates[tile.value - 1];
    final bboxDigit = tileDigitCoordinates[0];
    final offsetToCenterDigit = Offset(
      (sizeOfTile - bboxDigit.dx) / 2 - 3,
      (sizeOfTile - bboxDigit.dy) / 2 - 3,
    );
    for (var j = 1; j < tileDigitCoordinates.length; j++) {
      targetPositions
          .add(tileDigitCoordinates[j] + offset + offsetToCenterDigit);
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

  @override
  void dispose() {
    super.dispose();
    _ticker
      ..dispose()
      ..stop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PuzzleBloc, PuzzleState>(
      listener: (context, state) async {
        final changedTiles = _calculateChangedTilePositions(
          widget.state.puzzle.tiles,
          state.puzzle.tiles,
        );

        for (final movedTile in changedTiles) {
          _setTileTargetPositions(
            movedTile,
            _generateTargetPositions(movedTile, widget.spacing),
          );
        }
      },
      child: SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: Listener(
          onPointerDown: (event) {
            final referenceBox =
                _painterKey.currentContext!.findRenderObject() as RenderBox;
            final offset = referenceBox.globalToLocal(event.position);

            final x = _getClickPosition(offset.dx.toInt());
            final y = _getClickPosition(offset.dy.toInt());

            final clickedTile = widget.state.puzzle.tiles.firstWhere(
              (element) =>
                  element.currentPosition.x == x &&
                  element.currentPosition.y == y,
            );
            context.read<PuzzleBloc>().add(TileTapped(clickedTile));
          },
          child: CustomPaint(
            key: _painterKey,
            painter: MadParticlePainter(
              _particles.map((particle) => particle.position).toList(),
            ),
          ),
        ),
      ),
    );
  }

  int _getClickPosition(int clickPosition) {
    if (clickPosition < widget.size.width / 4) {
      return 1;
    }

    if (clickPosition < widget.size.width / 2) {
      return 2;
    }

    if (clickPosition < widget.size.width * 0.75) {
      return 3;
    }

    return 4;
  }

  void _setTileTargetPositions(Tile tile, List<Offset> targetPositions) {
    targetPositions.shuffle();
    for (var i = 0; i < targetPositions.length; i++) {
      _tileParticles[tile.value - 1][i].targetPosition = targetPositions[i];
    }
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

  List<Tile> _calculateChangedTilePositions(
    List<Tile> currentTiles,
    List<Tile> changedTiles,
  ) {
    final differences = <Tile>[];
    for (final changedTile in changedTiles) {
      if (changedTile.isWhitespace) continue;

      final respectiveCurrentTile = currentTiles
          .firstWhere((element) => changedTile.value == element.value);
      if (respectiveCurrentTile.currentPosition
              .compareTo(changedTile.currentPosition) !=
          0) {
        differences.add(changedTile);
      }
    }
    return differences;
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
      ..color = Colors.grey.shade800
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
