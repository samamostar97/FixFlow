import 'package:fixflow_desktop/constants/app_theme.dart';
import 'package:fixflow_desktop/screens/admin/dashboard_screen.dart';
import 'package:fixflow_desktop/widgets/layout/admin_shell_frame.dart';
import 'package:fixflow_desktop/widgets/layout/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'golden_test_helpers.dart';

void main() {
  const sidebarItems = <SidebarItem>[
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
  ];

  Widget buildHarness() {
    return MaterialApp(
      theme: darkTheme(),
      home: Scaffold(
        body: AdminShellFrame(
          selectedIndex: 0,
          onItemSelected: (_) {},
          onLogout: () {},
          items: sidebarItems,
          child: const DashboardScreen(),
        ),
      ),
    );
  }

  for (final width in smokeWidths) {
    final widthLabel = width.toInt();

    testWidgets('dashboard golden $widthLabel', (tester) async {
      await pumpGoldenHarness(tester, width: width, child: buildHarness());

      await expectLater(
        find.byType(Scaffold).first,
        matchesGoldenFile('baselines/dashboard_$widthLabel.png'),
      );
    });
  }
}
