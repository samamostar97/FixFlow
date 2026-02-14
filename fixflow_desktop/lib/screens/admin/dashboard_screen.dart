import 'package:fixflow_desktop/constants/app_spacing.dart';
import 'package:fixflow_desktop/screens/admin/widgets/dashboard_activity_panel.dart';
import 'package:fixflow_desktop/screens/admin/widgets/dashboard_kpi_strip.dart';
import 'package:fixflow_desktop/screens/admin/widgets/dashboard_ops_panels.dart';
import 'package:fixflow_desktop/screens/admin/widgets/dashboard_trend_panel.dart';
import 'package:fixflow_desktop/widgets/shared/admin_page_scaffold.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminPageScaffold(
      title: 'Dashboard',
      subtitle: 'Pregled kljucnih metrika i nedavnih promjena.',
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return SingleChildScrollView(
          child: Column(
            children: [
              DashboardKpiStrip(width: width),
              const SizedBox(height: AppSpacing.md),
              _buildInsightRow(width),
              const SizedBox(height: AppSpacing.md),
              _buildOperationsRow(width),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightRow(double width) {
    if (width < 900) {
      return const Column(
        children: [
          SizedBox(height: 320, child: DashboardTrendPanel()),
          SizedBox(height: AppSpacing.md),
          SizedBox(height: 320, child: DashboardActivityPanel()),
        ],
      );
    }

    return const SizedBox(
      height: 340,
      child: Row(
        children: [
          Expanded(flex: 2, child: DashboardTrendPanel()),
          SizedBox(width: AppSpacing.md),
          Expanded(child: DashboardActivityPanel()),
        ],
      ),
    );
  }

  Widget _buildOperationsRow(double width) {
    if (width < 1100) {
      return const Column(
        children: [
          SizedBox(height: 300, child: DashboardStatusBreakdownPanel()),
          SizedBox(height: AppSpacing.md),
          SizedBox(height: 340, child: DashboardUrgentRequestsPanel()),
        ],
      );
    }

    return const SizedBox(
      height: 300,
      child: Row(
        children: [
          Expanded(child: DashboardStatusBreakdownPanel()),
          SizedBox(width: AppSpacing.md),
          Expanded(child: DashboardUrgentRequestsPanel()),
        ],
      ),
    );
  }
}
