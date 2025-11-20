// lib/presentation/screens/v2/goal_lifetime_screen.dart
// ============================================================================
// GOAL LIFETIME SCREEN - Simplified version without progress history
// ============================================================================

import 'package:flutter/material.dart';

// Models and Services
import '../../../data/models/goal_model.dart';

// Components
import 'components/minimal_colors.dart';

class GoalLifetimeScreen extends StatelessWidget {
  final GoalModel goal;

  const GoalLifetimeScreen({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MinimalColors.backgroundPrimary(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Goal Details',
          style: TextStyle(
            color: MinimalColors.textPrimary(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: MinimalColors.textPrimary(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundCard(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MinimalColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    goal.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: MinimalColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(
                                fontSize: 14,
                                color: MinimalColors.textSecondary(context),
                              ),
                            ),
                            Text(
                              '${goal.currentValue}/${goal.targetValue}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: MinimalColors.textPrimary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Completion',
                              style: TextStyle(
                                fontSize: 14,
                                color: MinimalColors.textSecondary(context),
                              ),
                            ),
                            Text(
                              '${(goal.progress * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: MinimalColors.textPrimary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Progress history disabled notice
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MinimalColors.backgroundCard(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: MinimalColors.textSecondary(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Progress History Disabled',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: MinimalColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The detailed progress history and timeline features have been temporarily disabled.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: MinimalColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}