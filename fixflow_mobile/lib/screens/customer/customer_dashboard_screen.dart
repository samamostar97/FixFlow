import 'package:fixflow_mobile/providers/auth_provider.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_dashboard_blocks.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomerDashboardScreen extends ConsumerWidget {
  final VoidCallback onNavigateToRequests;

  const CustomerDashboardScreen({
    super.key,
    required this.onNavigateToRequests,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return MobilePageScaffold(
      title: 'Pocetna',
      subtitle: 'Zdravo, ${user?.firstName ?? ''}',
      scrollable: true,
      actions: const [_DashboardBellButton()],
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Brzi pregled vasih zahtjeva i poslova.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        const MobileDashboardKpiStrip(items: _kpiItems),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onNavigateToRequests,
          icon: const Icon(LucideIcons.wrench),
          label: const Text('Prijavi kvar'),
        ),
        const SizedBox(height: 16),
        const MobileDashboardActivityPanel(
          title: 'Nedavna aktivnost',
          items: _activityItems,
          emptyText: 'Nema nedavne aktivnosti.',
        ),
      ],
    );
  }
}

class _DashboardBellButton extends StatelessWidget {
  const _DashboardBellButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: const Icon(LucideIcons.bell), onPressed: () {});
  }
}

const _kpiItems = <MobileKpiItem>[
  MobileKpiItem(
    label: 'Aktivni zahtjevi',
    value: '--',
    trend: '+0%',
    icon: LucideIcons.wrench,
    accent: Color(0xFF22D3EE),
  ),
  MobileKpiItem(
    label: 'Poslovi u toku',
    value: '--',
    trend: '+0%',
    icon: LucideIcons.briefcase,
    accent: Color(0xFF10B981),
  ),
];

const _activityItems = <MobileActivityItem>[
  MobileActivityItem(
    icon: LucideIcons.filePlus,
    color: Color(0xFF22D3EE),
    title: 'Zahtjev je uspjesno kreiran',
    subtitle: 'Pratite ponude majstora u sekciji Zahtjevi.',
    time: 'sada',
  ),
  MobileActivityItem(
    icon: LucideIcons.badgeCheck,
    color: Color(0xFF10B981),
    title: 'Podsjetnik za status posla',
    subtitle: 'Otvorite Poslovi da vidite najnovije promjene.',
    time: 'tip',
  ),
];
