import 'package:data_table_2/data_table_2.dart';
import 'package:fixflow_desktop/constants/app_theme.dart';
import 'package:fixflow_desktop/widgets/shared/admin_page_scaffold.dart';
import 'package:fixflow_desktop/widgets/shared/app_data_table.dart';
import 'package:fixflow_desktop/widgets/shared/responsive_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'golden_test_helpers.dart';

class _AdminTableShellHarness extends StatelessWidget {
  const _AdminTableShellHarness();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: darkTheme(),
      home: Scaffold(
        body: AdminPageScaffold(
          title: 'Test tabela',
          subtitle: 'Golden baseline za responsive shell.',
          filters: ResponsiveFilterBar(
            compactBreakpoint: 760,
            primary: const TextField(
              decoration: InputDecoration(
                hintText: 'Pretrazi...',
                prefixIcon: Icon(LucideIcons.search),
              ),
            ),
            secondaryWidths: const [172, 172],
            secondary: [
              DropdownButtonFormField<int?>(
                initialValue: null,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Svi')),
                  DropdownMenuItem(value: 1, child: Text('Aktivni')),
                ],
                onChanged: (_) {},
              ),
              DropdownButtonFormField<int?>(
                initialValue: null,
                decoration: const InputDecoration(labelText: 'Tip'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Svi')),
                  DropdownMenuItem(value: 1, child: Text('On-site')),
                ],
                onChanged: (_) {},
              ),
            ],
          ),
          actions: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.plus),
            label: const Text('Dodaj stavku'),
          ),
          body: AppDataTable(
            minWidth: 980,
            columns: const [
              DataColumn2(label: Text('ID'), fixedWidth: 70),
              DataColumn2(label: Text('Naziv'), size: ColumnSize.L),
              DataColumn2(label: Text('Status'), fixedWidth: 120),
              DataColumn2(label: Text('Datum'), fixedWidth: 132),
              DataColumn2(label: Text('Akcije'), fixedWidth: 124),
            ],
            rows: List.generate(
              4,
              (index) => DataRow(
                cells: [
                  DataCell(Text('#${index + 1}')),
                  DataCell(Text('Test stavka ${index + 1}')),
                  const DataCell(Text('Aktivno')),
                  const DataCell(Text('13.02.2026.')),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(LucideIcons.pencil, size: 16),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(LucideIcons.trash2, size: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  for (final width in smokeWidths) {
    final widthLabel = width.toInt();

    testWidgets('table shell golden $widthLabel', (tester) async {
      await pumpGoldenHarness(
        tester,
        width: width,
        child: const _AdminTableShellHarness(),
      );

      await expectLater(
        find.byType(Scaffold).first,
        matchesGoldenFile('baselines/table_shell_$widthLabel.png'),
      );
    });
  }
}
