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

  Future<void> pumpShell(WidgetTester tester, double width) async {
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });
    await tester.binding.setSurfaceSize(Size(width, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminShellFrame(
            selectedIndex: 0,
            onItemSelected: (_) {},
            onLogout: () {},
            items: sidebarItems,
            child: const Center(child: Text('Body')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows full sidebar on wide desktop', (tester) async {
    await pumpShell(tester, 1366);

    expect(find.text('Admin Dashboard'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Body'), findsOneWidget);
  });

  testWidgets('switches to rail mode under 1200 width', (tester) async {
    await pumpShell(tester, 1024);

    expect(find.text('Admin Dashboard'), findsNothing);
    expect(find.text('Body'), findsOneWidget);
    expect(find.byIcon(LucideIcons.layoutDashboard), findsWidgets);
  });
}
