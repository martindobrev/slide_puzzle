// ignore_for_file: type_annotate_public_apis

import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vecmath;
import 'package:very_good_slide_puzzle/models/models.dart';

class Particle {
  Offset position;
  double speed;
  double direction;
  Tile tile;

  Offset? targetPosition;

  Particle(this.position, this.speed, this.direction, this.tile);

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

    Offset diff = targetPosition! - position;
    Offset offset = Offset.fromDirection(diff.direction, 4);

    if (diff.distance > offset.distance) {
      return position + offset;
    }

    return targetPosition!;
  }
}
