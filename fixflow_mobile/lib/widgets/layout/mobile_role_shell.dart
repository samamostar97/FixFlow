import 'package:flutter/material.dart';
import 'package:fixflow_mobile/constants/app_density.dart';

class MobileRoleShell extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget> screens;
  final List<NavigationDestination> destinations;

  const MobileRoleShell({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.screens,
    required this.destinations,
  }) : assert(screens.length == destinations.length);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: cs.outline)),
          ),
          child: NavigationBar(
            height: AppDensity.bottomNavHeight,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: destinations,
          ),
        ),
      ),
    );
  }
}
