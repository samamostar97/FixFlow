import 'package:fixflow_desktop/constants/app_theme.dart';
import 'package:fixflow_desktop/providers/auth_provider.dart';
import 'package:fixflow_desktop/screens/admin/bookings_screen.dart';
import 'package:fixflow_desktop/screens/admin/dashboard_screen.dart';
import 'package:fixflow_desktop/screens/admin/offers_screen.dart';
import 'package:fixflow_desktop/screens/admin/repair_categories_screen.dart';
import 'package:fixflow_desktop/screens/admin/repair_requests_screen.dart';
import 'package:fixflow_desktop/screens/admin/payments_screen.dart';
import 'package:fixflow_desktop/screens/admin/technician_profiles_screen.dart';
import 'package:fixflow_desktop/screens/auth/login_screen.dart';
import 'package:fixflow_desktop/widgets/layout/admin_shell_frame.dart';
import 'package:fixflow_desktop/widgets/layout/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

void main() {
  runApp(const ProviderScope(child: FixFlowDesktopApp()));
}

class FixFlowDesktopApp extends StatelessWidget {
  const FixFlowDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixFlow Admin',
      debugShowCheckedModeBanner: false,
      theme: darkTheme(),
      home: const _AppShell(),
    );
  }
}

class _AppShell extends ConsumerWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.user == null) {
      return const LoginScreen();
    }

    return const _AdminDashboard();
  }
}

class _AdminDashboard extends ConsumerStatefulWidget {
  const _AdminDashboard();

  @override
  ConsumerState<_AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<_AdminDashboard> {
  int _selectedIndex = 0;

  static const _sidebarItems = <SidebarItem>[
    SidebarItem(
      icon: LucideIcons.layoutDashboard,
      selectedIcon: LucideIcons.layoutDashboard,
      label: 'Dashboard',
    ),
    SidebarItem(
      icon: LucideIcons.wrench,
      selectedIcon: LucideIcons.wrench,
      label: 'Zahtjevi',
      section: 'Upravljanje',
    ),
    SidebarItem(
      icon: LucideIcons.messageSquare,
      selectedIcon: LucideIcons.messageSquare,
      label: 'Ponude',
    ),
    SidebarItem(
      icon: LucideIcons.briefcase,
      selectedIcon: LucideIcons.briefcase,
      label: 'Poslovi',
    ),
    SidebarItem(
      icon: LucideIcons.creditCard,
      selectedIcon: LucideIcons.creditCard,
      label: 'Uplate',
    ),
    SidebarItem(
      icon: LucideIcons.userCog,
      selectedIcon: LucideIcons.userCog,
      label: 'Majstori',
      section: 'Korisnici',
    ),
    SidebarItem(
      icon: LucideIcons.folderOpen,
      selectedIcon: LucideIcons.folderOpen,
      label: 'Kategorije',
      section: 'Sistem',
    ),
  ];

  static const _screens = <Widget>[
    DashboardScreen(),
    RepairRequestsScreen(),
    OffersScreen(),
    BookingsScreen(),
    PaymentsScreen(),
    TechnicianProfilesScreen(),
    RepairCategoriesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdminShellFrame(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
        onLogout: () => ref.read(authProvider.notifier).logout(),
        items: _sidebarItems,
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),
    );
  }
}
