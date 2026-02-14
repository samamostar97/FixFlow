import 'package:fixflow_desktop/screens/admin/dashboard_screen.dart';
import 'package:fixflow_desktop/widgets/layout/admin_shell_frame.dart';
import 'package:fixflow_desktop/widgets/layout/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

  Future<void> pumpDashboard(WidgetTester tester, double width) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(Size(width, 900));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminShellFrame(
            selectedIndex: 0,
            onItemSelected: (_) {},
            onLogout: () {},
            items: sidebarItems,
            child: const DashboardScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'renders dashboard KPI layout without overflow on target widths',
    (tester) async {
      const widths = <double>[1536, 1366, 1200, 1024, 860];

      for (final width in widths) {
        await pumpDashboard(tester, width);

        expect(find.text('Aktivni zahtjevi'), findsOneWidget);
        expect(find.text('Aktivni majstori'), findsOneWidget);
        expect(find.text('Zavrsene popravke'), findsOneWidget);
        expect(find.text('Ukupan prihod'), findsOneWidget);
        expect(find.text('Prioritetni slucajevi'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
