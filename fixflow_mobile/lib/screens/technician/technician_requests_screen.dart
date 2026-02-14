import 'package:fixflow_mobile/screens/technician/my_offers_screen.dart';
import 'package:fixflow_mobile/screens/technician/open_repair_requests_screen.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_page_scaffold.dart';
import 'package:fixflow_mobile/widgets/shared/mobile_top_tabs_section.dart';
import 'package:flutter/material.dart';

class TechnicianRequestsScreen extends StatelessWidget {
  const TechnicianRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MobilePageScaffold(
      title: 'Zahtjevi',
      subtitle: 'Otvoreni zahtjevi i vase ponude.',
      contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      body: const MobileTopTabsSection(
        tabs: [
          Tab(text: 'Otvoreni'),
          Tab(text: 'Moje ponude'),
        ],
        children: [OpenRepairRequestsScreen(), MyOffersScreen()],
      ),
    );
  }
}
