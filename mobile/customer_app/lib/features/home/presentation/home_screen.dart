import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import 'feature_card.dart';

/// Demo home screen for the HerCare customer app.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _services = <({IconData icon, String title})>[
    (icon: Icons.cleaning_services_outlined, title: 'Home Cleaning'),
    (icon: Icons.water_drop_outlined, title: 'Dishwashing'),
    (icon: Icons.local_laundry_service_outlined, title: 'Laundry Assistance'),
  ];

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customer App Demo — Coming Soon')),
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
                      'HerCare',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.lavender,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome to HerCare',
                  style: textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find trusted home helpers for your everyday needs.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.deepPlum.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 28),
                for (final s in _services) ...[
                  FeatureCard(icon: s.icon, title: s.title),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _showComingSoon(context),
                  child: const Text('Explore Services'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
