import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_size_manager/features/games/presentation/cubit/games_cubit.dart';
import 'package:game_size_manager/features/games/presentation/cubit/games_state.dart';

class RefreshProgressOverlay extends StatelessWidget {
  const RefreshProgressOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GamesCubit, GamesState>(
      builder: (context, state) {
        final progress = state.maybeWhen(
          loading: (p) => p,
          loaded: (_, __, ___, ____, p) => p,
          orElse: () => null,
        );

        if (progress == null) return const SizedBox.shrink();

        return Container(
          color: Colors.black.withValues(alpha: 0.8),
          child: Center(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Emphasized Fun Phrase
                    Text(
                      progress.funPhrase,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Technical Phase
                    Text(
                      progress.currentPhase,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Progress Bar
                    LinearProgressIndicator(
                      value: progress.progressPercent,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 8),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress.progressPercent * 100).toInt()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (progress.estimatedTimeRemaining != null)
                          Text(
                            '~${progress.estimatedTimeRemaining!.inSeconds}s remaining',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
