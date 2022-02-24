import 'package:very_good_slide_puzzle/layout/puzzle_layout_delegate.dart';
import 'package:very_good_slide_puzzle/madparticles/madparticles_layout_delegate.dart';
import 'package:very_good_slide_puzzle/simple/simple.dart';

/// Theme for the MadParticles puzzle
///
/// Simple extension of the simple theme.
/// Only changed name and layoutDelegate.
class MadParticlesTheme extends SimpleTheme {
  /// MadParticlesTheme constructor
  const MadParticlesTheme() : super();

  @override
  String get name => 'MadParticles';

  @override
  PuzzleLayoutDelegate get layoutDelegate => const MadParticlesLayoutDelegate();
}
