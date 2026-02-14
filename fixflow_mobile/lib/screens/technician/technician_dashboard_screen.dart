import 'package:fixflow_mobile/providers/auth_provider.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_dashboard_blocks.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TechnicianDashboardScreen extends ConsumerWidget {
  final VoidCallback onNavigateToRequests;

  const TechnicianDashboardScreen({
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
          'Pratite otvorene zahtjeve i aktivne ponude.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        const MobileDashboardKpiStrip(items: _kpiItems),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onNavigateToRequests,
          icon: const Icon(LucideIcons.search),
          label: const Text('Pregledaj zahtjeve'),
        ),
        const SizedBox(height: 16),
        const MobileDashboardActivityPanel(
          title: 'Nedavna aktivnost',
          items: _activityItems,
          emptyText: 'Nema novih aktivnosti trenutno.',
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
    label: 'Otvoreni zahtjevi',
    value: '--',
    trend: '+0%',
    icon: LucideIcons.search,
    accent: Color(0xFF22D3EE),
  ),
  MobileKpiItem(
    label: 'Aktivne ponude',
    value: '--',
    trend: '+0%',
    icon: LucideIcons.messageSquare,
    accent: Color(0xFFA78BFA),
  ),
];

const _activityItems = <MobileActivityItem>[
  MobileActivityItem(
    icon: LucideIcons.badgeDollarSign,
    color: Color(0xFFA78BFA),
    title: 'Posaljite ponudu na novi zahtjev',
    subtitle: 'Sekcija Zahtjevi prikazuje najnovije otvorene kvarove.',
    time: 'tip',
  ),
  MobileActivityItem(
    icon: LucideIcons.briefcase,
    color: Color(0xFF10B981),
    title: 'Azurirajte status aktivnih poslova',
    subtitle: 'Status promjene podizu transparentnost prema korisniku.',
    time: 'tip',
  ),
];
