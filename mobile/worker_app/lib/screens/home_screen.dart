import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/feature_card.dart';

/// Demo home screen for the HerCare worker app.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _items = <({IconData icon, String title})>[
    (icon: Icons.work_outline, title: 'Available Jobs'),
    (icon: Icons.assignment_outlined, title: 'My Assignments'),
    (icon: Icons.account_balance_wallet_outlined, title: 'My Earnings'),
  ];

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Worker App Demo — Coming Soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.lavender,
                      child: Icon(Icons.favorite, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'HerCare Worker',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.lavender,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome, Helper!',
                  style: textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your work and opportunities in one place.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.deepPlum.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 28),
                for (final item in _items) ...[
                  FeatureCard(icon: item.icon, title: item.title),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _showComingSoon(context),
                  child: const Text('View Jobs'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
