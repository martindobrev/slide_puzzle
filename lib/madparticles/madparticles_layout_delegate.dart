import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_slide_puzzle/layout/layout.dart';
import 'package:very_good_slide_puzzle/madparticles/mad_particle_controller.dart';
import 'package:very_good_slide_puzzle/puzzle/puzzle.dart';
import 'package:very_good_slide_puzzle/simple/simple_puzzle_layout_delegate.dart';

///
/// MadParticles Layout Delegate
///
/// Overrides the boardBuilder method to display the
/// modified MadParticlesPuzzleBoard
///
class MadParticlesLayoutDelegate extends SimplePuzzleLayoutDelegate {
  /// Constructor
  const MadParticlesLayoutDelegate() : super();

  @override
  Widget boardBuilder(int size, List<Widget> tiles) {
    return Column(
      children: [
        const ResponsiveGap(
          small: 32,
          medium: 48,
          large: 96,
        ),
        ResponsiveLayoutBuilder(
          small: (_, __) => SizedBox.square(
            dimension: _BoardSize.small,
            child: MadParticlesPuzzleBoard(
              key: const Key('mad_puzzle_board_small'),
              size: _BoardSize.small.toInt(),
              tiles: tiles,
              spacing: 5,
            ),
          ),
          medium: (_, __) => SizedBox.square(
            dimension: _BoardSize.medium,
            child: MadParticlesPuzzleBoard(
              key: const Key('mad_puzzle_board_medium'),
              size: _BoardSize.medium.toInt(),
              tiles: tiles,
            ),
          ),
          large: (_, __) => SizedBox.square(
            dimension: _BoardSize.large,
            child: MadParticlesPuzzleBoard(
              key: const Key('mad_puzzle_board_large'),
              size: _BoardSize.large.toInt(),
              tiles: tiles,
            ),
          ),
        ),
        const ResponsiveGap(
          large: 96,
        ),
      ],
    );
  }
}

abstract class _BoardSize {
  static double small = 312;
  static double medium = 424;
  static double large = 472;
}

/// Puzzle board for the MadParticles
class MadParticlesPuzzleBoard extends StatelessWidget {
  /// Constructor
  const MadParticlesPuzzleBoard({
    Key? key,
    required this.size,
    required this.tiles,
    this.spacing = 8,
  }) : super(key: key);

  /// The size of the board.
  final int size;

  /// The tiles to be displayed on the board.
  final List<Widget> tiles;

  /// The spacing between each tile from [tiles].
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final state = context.select((PuzzleBloc bloc) => bloc.state);
    return SizedBox(
      width: size.toDouble(),
      height: size.toDouble(),
      child: MadParticleController(
        Size(size.toDouble(), size.toDouble()),
        400, // parameter left for experiments, currently unused
        state,
        spacing,
        key: const Key('particle controller'),
      ),
    );
  }
}
