// ignore_for_file: type_annotate_public_apis

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vecmath;
import 'package:very_good_slide_puzzle/models/models.dart';

/// Represents a dot in the MadParticle puzzle board
///
/// The class is a simple helper that calculates the movements of a single
/// particle in the MadParticles puzzle board
class Particle {
  /// Particle class constructor with its basic properties
  Particle(
    this.position,
    this.speed,
    this.direction,
    this.tile,
    this.easingFunction,
    this.framesToTarget,
  );

  /// current position of the particle
  /// Since particles can move across the whole puzzle board, the position
  /// is an offset based on this board
  Offset position;

  /// Speed of the particle measured in how many pixels the particle
  /// moves per frame
  final double speed;

  /// Direction of the particle measured in degrees
  double direction;

  /// Tile that the particle belongs to
  final Tile tile;

  /// Easing function to use when
  final double Function(double) easingFunction;

  /// Number of frames for the animation to reach the target position
  final int framesToTarget;

  /// When not set, particles move freely across the puzzle board.
  /// If a target position is set, the particle will change its direction
  /// towards the target position (final destination). When the destination is
  /// reached, the particle will its movement.
  Offset? _targetPosition;

  /// Setter for the target position
  ///
  /// Initiates the calculation of the EaseOutCubic animation towards target
  /// For that the current position needs to be stored, also the frame counter
  /// is resetted
  ///
  set targetPosition(Offset? targetPosition) {
    _targetMovementStartPosition = position;
    _animationToTargetFrame = 0;
    _targetPosition = targetPosition;
  }

  /// Getter for the target position
  Offset? get targetPosition => _targetPosition;

  Offset _targetMovementStartPosition = Offset.zero;

  int _animationToTargetFrame = 0;

  Offset _getNextPosition(Size size) {
    var offset =
        Offset.fromDirection(vecmath.radians(direction), speed) + position;

    if (offset.dx > size.width) {
      final diffX = offset.dx - size.width;

      offset = Offset(size.width - diffX, offset.dy);
      direction = 180 - direction;
    }

    if (offset.dx < 0) {
      final diffX = offset.dx.abs();
      offset = Offset(diffX, offset.dy);
      direction = 180 - direction;
    }

    if (offset.dy > size.height) {
      final diffY = offset.dy - size.height;
      offset = Offset(offset.dx, size.height - diffY);
      direction = 360 - direction;
    }

    if (offset.dy < 0) {
      final diffY = offset.dy.abs();
      offset = Offset(offset.dx, diffY);
      direction = 360 - direction;
    }

    return offset;
  }

  /// Moves the particle to the next position
  ///
  /// Calculates the next position based on the current position, speed and
  /// direction. If the particle has a target position, moves it closer
  /// to the target position
  ///
  void move(Size size) {
    if (_targetPosition == null) {
      position = _getNextPosition(size);
    } else {
      position = _getNextPositionCloserToTarget(size);
      _animationToTargetFrame++;
    }
  }

  Offset _getNextPositionCloserToTarget(Size size) {
    if (_animationToTargetFrame < framesToTarget) {
      return position + _calculateEaseInOutOffset();
    } else {
      return _targetPosition!;
    }
  }

  Offset _calculateEaseInOutOffset() {
    final diff = _targetPosition! - position;
    final dx = diff.dx;
    final dy = diff.dy;

    final animationProgress = _animationToTargetFrame / framesToTarget;

    return Offset(dx * easingFunction(animationProgress),
        dy * easingFunction(animationProgress));
  }
}

///
/// Easing functions
///
/// Copied from easings.net
///

double _easeOutCubic(double x) {
  return (1 - pow(1 - x, 3)).toDouble();
}

double _easeInSine(double x) {
  return 1 - cos((x * pi) / 2);
}

double _easeOutSine(double x) {
  return sin((x * pi) / 2);
}

double _easeInOutCirc(double x) {
  return x < 0.5
      ? (1 - sqrt(1 - pow(2 * x, 2))) / 2
      : (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2;
}

double _easeInQuint(double x) {
  return x * x * x * x * x;
}

double _easeInCubic(double x) {
  return x * x * x;
}

///
/// List of all available easing functions
///
const easingFunctionList = [
  _easeInCubic,
  _easeInSine,
  _easeOutSine,
  _easeInOutCirc,
  _easeInQuint,
  _easeInCubic,
  _easeOutCubic,
];
