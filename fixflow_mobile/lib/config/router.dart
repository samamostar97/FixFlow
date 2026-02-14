import 'package:fixflow_core/fixflow_core.dart';
import 'package:fixflow_mobile/providers/auth_provider.dart';
import 'package:fixflow_mobile/screens/auth/login_screen.dart';
import 'package:fixflow_mobile/screens/customer/customer_dashboard_screen.dart';
import 'package:fixflow_mobile/screens/customer/my_bookings_screen.dart';
import 'package:fixflow_mobile/screens/customer/my_repair_requests_screen.dart';
import 'package:fixflow_mobile/screens/technician/my_jobs_screen.dart';
import 'package:fixflow_mobile/screens/technician/technician_dashboard_screen.dart';
import 'package:fixflow_mobile/screens/technician/technician_profile_screen.dart';
import 'package:fixflow_mobile/screens/technician/technician_requests_screen.dart';
import 'package:fixflow_mobile/widgets/layout/mobile_role_shell.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const LoginScreen();
    }

    switch (user.role.name) {
      case 'customer':
        return const _CustomerHome();
      case 'technician':
        return const _TechnicianHome();
      default:
        return const _CustomerHome();
    }
  }
}

class _CustomerHome extends StatefulWidget {
  const _CustomerHome();

  @override
  State<_CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<_CustomerHome> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return MobileRoleShell(
      selectedIndex: _currentIndex,
      onDestinationSelected: _navigateToTab,
      screens: [
        CustomerDashboardScreen(onNavigateToRequests: () => _navigateToTab(1)),
        const MyRepairRequestsScreen(),
        const MyBookingsScreen(),
        const _CustomerProfilePlaceholder(),
      ],
      destinations: const [
        NavigationDestination(
          icon: Icon(LucideIcons.home),
          selectedIcon: Icon(LucideIcons.home),
          label: 'Pocetna',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.wrench),
          selectedIcon: Icon(LucideIcons.wrench),
          label: 'Zahtjevi',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.briefcase),
          selectedIcon: Icon(LucideIcons.briefcase),
          label: 'Poslovi',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.user),
          selectedIcon: Icon(LucideIcons.user),
          label: 'Profil',
        ),
      ],
    );
  }
}

class _TechnicianHome extends StatefulWidget {
  const _TechnicianHome();

  @override
  State<_TechnicianHome> createState() => _TechnicianHomeState();
}

class _TechnicianHomeState extends State<_TechnicianHome> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return MobileRoleShell(
      selectedIndex: _currentIndex,
      onDestinationSelected: _navigateToTab,
      screens: [
        TechnicianDashboardScreen(
          onNavigateToRequests: () => _navigateToTab(1),
        ),
        const TechnicianRequestsScreen(),
        const MyJobsScreen(),
        const TechnicianProfileScreen(),
      ],
      destinations: const [
        NavigationDestination(
          icon: Icon(LucideIcons.home),
          selectedIcon: Icon(LucideIcons.home),
          label: 'Pocetna',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.search),
          selectedIcon: Icon(LucideIcons.search),
          label: 'Zahtjevi',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.briefcase),
          selectedIcon: Icon(LucideIcons.briefcase),
          label: 'Poslovi',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.user),
          selectedIcon: Icon(LucideIcons.user),
          label: 'Profil',
        ),
      ],
    );
  }
}

class _CustomerProfilePlaceholder extends ConsumerWidget {
  const _CustomerProfilePlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MobilePageScaffold(
      title: 'Profil',
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.logOut),
          onPressed: () => ref.read(authProvider.notifier).logout(),
        ),
      ],
      body: _buildProfileBody(context, ref.watch(authProvider).user!),
    );
  }

  Widget _buildProfileBody(BuildContext context, UserResponse user) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        MobileSectionCard(
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.15,
                ),
                child: Text(
                  '${user.firstName[0]}${user.lastName[0]}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${user.firstName} ${user.lastName}',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
