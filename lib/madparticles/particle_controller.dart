import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:very_good_slide_puzzle/madparticles/particle.dart';

class ParticleController extends StatefulWidget {
  final int numberOfParticles;
  final Size size;

  ParticleController(this.size, this.numberOfParticles, {required Key key})
      : super(key: key);
  @override
  State<StatefulWidget> createState() =>
      ParticleControllerState(this.size, this.numberOfParticles);
}

class ParticleControllerState extends State<ParticleController> {
  final Size size;
  final int numberOfParticles;
  ParticleControllerState(this.size, this.numberOfParticles) {
    final random = Random();

    for (var i = 0; i < this.numberOfParticles; i++) {
      final initialOffset = Offset(
          random.nextInt(size.width.toInt()).toDouble(),
          random.nextInt(size.height.toInt()).toDouble());
      final speed = 0.5 + random.nextInt(2).toDouble();
      final direction = random.nextDouble() * 360;
      particles.add(Particle(initialOffset, speed, direction));
    }
  }

  List<Particle> particles = [];
  List<Offset> get particlePositions =>
      this.particles.map((particle) => particle.position).toList();

  List<Offset> targetPositions = [];
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_tick);
    _ticker.start();
  }

  void _tick(Duration duration) {
    this.particles.forEach((particle) => particle.move(this.size));
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    print('DISPOSED');

    if (_ticker != null) {
      _ticker.dispose();
      _ticker.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size.width,
        height: size.height,
        child:
            CustomPaint(painter: MadParticlePainter(this.particlePositions)));
  }

  void setTargetPositions(List<Offset> offsets) {
    if (offsets == null || offsets.isEmpty) {
      for (var i = 0; i < this.particles.length; i++) {
        this.particles[i].targetPosition = null;
      }
      return;
    }

    var ratio = 1.0;
    if (offsets.length > this.particles.length) {
      ratio = offsets.length / this.particles.length;
      for (var i = 0; i < this.particles.length; i++) {
        this.particles[i].targetPosition = offsets[(i * ratio).ceil()];
      }
    } else {
      for (var i = 0; i < offsets.length; i++) {
        this.particles[i].targetPosition = offsets[i];
      }
    }
  }
}

class MadParticlePainter extends CustomPainter {
  final List<Offset> particles;

  MadParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    Paint normalPaint = Paint();
    normalPaint.color = Colors.black;
    normalPaint.strokeWidth = 2;
    normalPaint.strokeCap = StrokeCap.round;
    normalPaint.blendMode = BlendMode.colorBurn;
    canvas.drawPoints(PointMode.points, this.particles, normalPaint);

    Paint backgroundPaint = Paint();
    backgroundPaint.color = Colors.white;
    backgroundPaint.strokeWidth = 10;
    backgroundPaint.style = PaintingStyle.stroke;
    backgroundPaint.blendMode = BlendMode.exclusion;

    //canvas.drawCircle(Offset(150, 150), size.shortestSide * 0.4, backgroundPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
