import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/art.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/data/session.dart';
import '../../jobs/data/work_store.dart';
import '../../jobs/domain/job.dart';
import '../../rewards/data/rewards_store.dart';
import '../../shifts/data/shift_store.dart';
import '../../support/presentation/sos_sheet.dart';
import 'alert_carousel.dart';
import 'home_tab_provider.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  void _toggle(WidgetRef ref, bool online) {
    HapticFeedback.mediumImpact();
    ref.read(workProvider.notifier).setOnline(online);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final work = ref.watch(workProvider);
    final session = ref.watch(sessionProvider);
    final coins = ref.watch(rewardsProvider);
    final today = ref.watch(todayProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Row(
            children: [
              Pressable(
                label: 'Open profile',
                onTap: () =>
                    ref.read(homeTabProvider.notifier).show(HomeTabId.profile),
                child: const ExpertAvatar(size: 46),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${session.firstName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      dayDate(today),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Pressable(
                label: '$coins coins',
                onTap: () => context.push(Routes.coins),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: softShadow(),
                  ),
                  child: Row(
                    children: [
                      const CoinIcon(size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '$coins',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Pressable(
                label: 'Emergency SOS',
                onTap: () => showSosSheet(context),
                child: const IconTile(
                  Icons.sos_rounded,
                  size: 40,
                  color: AppColors.danger,
                  fill: AppColors.dangerSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Pressable(
            label: 'Weekend bonus. Open updates',

            onTap: () =>
                ref.read(homeTabProvider.notifier).show(HomeTabId.updates),

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

              margin: const EdgeInsets.only(bottom: 14),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.lavenderDeep, AppColors.lavender],
                ),

                borderRadius: BorderRadius.circular(18),
              ),

              child: Row(
                children: [
                  Loop(
                    duration: const Duration(milliseconds: 2400),

                    builder: (context, t) => CoinIcon(size: 26, turn: t),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      'Weekend bonus: ₹300 extra for 6 jobs',

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ),

          Reveal(
            index: 0,
            child: _StatusCard(work: work, onChanged: (v) => _toggle(ref, v)),
          ),
          if (work.active != null) ...[
            const SizedBox(height: 14),
            _ActiveJobCard(job: work.active!, stage: work.stage),
          ],
          const SectionTitle('Today'),
          Reveal(
            index: 1,
            child: Row(
              children: [
                _Stat(
                  'Earned',
                  work.earnedToday,
                  rupees,
                  Icons.payments_rounded,
                ),
                const SizedBox(width: 12),
                _Stat(
                  'Jobs',
                  work.jobsToday,
                  (v) => '$v',
                  Icons.task_alt_rounded,
                ),
                const SizedBox(width: 12),
                _Stat(
                  'Time',
                  work.minutesToday,
                  (v) => '${v.toInt() ~/ 60}h ${v.toInt() % 60}m',
                  Icons.schedule_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Reveal(index: 2, child: const _TomorrowCard()),
          const SectionTitle('For you'),
          Reveal(index: 3, child: const AlertCarousel()),
          const SizedBox(height: 14),
          AppCard(
            gradient: const LinearGradient(
              colors: [AppColors.softLavender, AppColors.roseSoft],
            ),
            onTap: () =>
                ref.read(homeTabProvider.notifier).show(HomeTabId.refer),
            child: const Row(
              children: [
                IconTile(Icons.group_add_rounded, fill: AppColors.card),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bring a friend, earn together',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Up to ₹5,000 for each friend who joins',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Map, pulse and the online switch.
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.work, required this.onChanged});

  final WorkState work;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final online = work.online;
    final title = !online
        ? 'You are offline'
        : work.active != null
        ? 'You are on a job'
        : 'Looking for jobs nearby';
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: softShadow(1.4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 190,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: CustomPaint(painter: MapPainter()),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    color: online
                        ? AppColors.clear
                        : AppColors.card.withValues(alpha: 0.55),
                  ),
                ),
                PulseRings(
                  size: 170,
                  active: online,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      shape: BoxShape.circle,
                      boxShadow: softShadow(2),
                    ),
                    child: const ExpertAvatar(size: 52, label: 'Your location'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    title,
                    key: ValueKey(title),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  online
                      ? 'Keep the app open and your phone charged'
                      : 'Go online to start getting requests',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 14),
                OnlineToggle(
                  online: online,
                  enabled: work.active == null,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Wide switch that can be tapped or dragged.
class OnlineToggle extends StatelessWidget {
  const OnlineToggle({
    super.key,
    required this.online,
    required this.enabled,
    required this.onChanged,
  });

  final bool online;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = online ? AppColors.success : AppColors.lavender;
    return Semantics(
      toggled: online,
      button: true,
      enabled: enabled,
      label: online ? 'Online. Tap to go offline' : 'Offline. Tap to go online',
      excludeSemantics: true,
      onTap: enabled ? () => onChanged(!online) : null,
      child: GestureDetector(
        key: const ValueKey('online-toggle'),
        onTap: enabled ? () => onChanged(!online) : null,
        onHorizontalDragEnd: enabled
            ? (d) {
                final right = (d.primaryVelocity ?? 0) > 0;
                if (right != online) onChanged(right);
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 62,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  online ? 'Online' : 'Go online',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                alignment: online
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    online
                        ? Icons.check_rounded
                        : Icons.power_settings_new_rounded,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  const _ActiveJobCard({required this.job, required this.stage});

  final Job job;
  final JobStage stage;

  @override
  Widget build(BuildContext context) => AppCard(
    color: AppColors.lavender,
    onTap: () => context.push(Routes.job),
    child: Row(
      children: [
        const IconTile(Icons.cleaning_services_rounded, fill: AppColors.card),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${job.service} · ${stage.label}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${job.customer}, ${job.area}',
                style: const TextStyle(color: AppColors.white, fontSize: 12.5),
              ),
            ],
          ),
        ),
        const Text(
          'Resume',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
        ),
        const Icon(Icons.chevron_right_rounded, color: AppColors.white),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.format, this.icon);

  final String label;
  final int value;
  final String Function(num) format;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Expanded(
    child: AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.lavender),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: CountUp(
              value: value,
              format: format,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
        ],
      ),
    ),
  );
}

class _TomorrowCard extends ConsumerWidget {
  const _TomorrowCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final present = ref.watch(shiftProvider.select((s) => s.tomorrowPresent));
    return AppCard(
      onTap: () => context.push(Routes.attendance),
      child: Row(
        children: [
          const IconTile(Icons.event_available_rounded),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tomorrow's shift",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  '9:00 AM – 5:00 PM',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          switch (present) {
            null => const Pill(
              'Confirm',
              color: AppColors.warning,
              fill: AppColors.warningSoft,
            ),
            true => const Pill(
              'Present',
              color: AppColors.success,
              fill: AppColors.successSoft,
            ),
            false => const Pill(
              'Absent',
              color: AppColors.danger,
              fill: AppColors.dangerSoft,
            ),
          },
        ],
      ),
    );
  }
}
