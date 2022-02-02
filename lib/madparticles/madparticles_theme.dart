import 'dart:ui';
import 'package:very_good_slide_puzzle/layout/puzzle_layout_delegate.dart';
import 'package:very_good_slide_puzzle/madparticles/madparticles_layout_delegate.dart';
import 'package:very_good_slide_puzzle/simple/simple.dart';

class MadParticlesTheme extends SimpleTheme {
  /// MadParticlesTheme constructor
  const MadParticlesTheme() : super();

  @override
  String get name => 'MadParticles';

  @override
  PuzzleLayoutDelegate get layoutDelegate => const MadParticlesLayoutDelegate();
}
