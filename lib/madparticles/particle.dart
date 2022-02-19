// ignore_for_file: type_annotate_public_apis

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
  Particle(this.position, this.speed, this.direction, this.tile);

  /// current position of the particle
  /// Since particles can move across the whole puzzle board, the position
  /// is an offset based on this board
  Offset position;

  /// Speed of the particle measured in how many pixels the particle
  /// moves per frame
  double speed;

  /// Direction of the particle measured in degrees
  double direction;

  /// Tile that the particle belongs to
  Tile tile;

  /// When not set, particles move freely across the puzzle board.
  /// If a target position is set, the particle will change its direction
  /// towards the target position (final destination). When the destination is
  /// reached, the particle will its movement.
  Offset? targetPosition;

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
    if (targetPosition == null) {
      position = _getNextPosition(size);
    } else {
      position = _getNextPositionCloserToTarget(size);
    }
  }

  Offset _getNextPositionCloserToTarget(Size size) {
    if (targetPosition == null) {
      return Offset.zero;
    }

    final diff = targetPosition! - position;
    final offset = Offset.fromDirection(diff.direction, speed);

    if (diff.distance > offset.distance) {
      return position + offset;
    }

    return targetPosition!;
  }
}
