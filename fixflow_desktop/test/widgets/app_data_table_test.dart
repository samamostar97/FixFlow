import 'package:data_table_2/data_table_2.dart';
import 'package:fixflow_desktop/widgets/shared/app_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders header and row data', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 320,
            width: 720,
            child: AppDataTable(
              minWidth: 900,
              columns: const [
                DataColumn2(label: Text('ID'), fixedWidth: 70),
                DataColumn2(label: Text('Naziv'), size: ColumnSize.L),
              ],
              rows: const [
                DataRow(
                  cells: [DataCell(Text('#1')), DataCell(Text('Test red'))],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('ID'), findsOneWidget);
    expect(find.text('Naziv'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('Test red'), findsOneWidget);
  });

  testWidgets('keeps scroll infrastructure for narrow width', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 320,
            width: 480,
            child: AppDataTable(
              minWidth: 1000,
              columns: const [
                DataColumn2(label: Text('A'), fixedWidth: 120),
                DataColumn2(label: Text('B'), fixedWidth: 120),
                DataColumn2(label: Text('C'), fixedWidth: 120),
                DataColumn2(label: Text('D'), fixedWidth: 120),
                DataColumn2(label: Text('E'), fixedWidth: 120),
                DataColumn2(label: Text('F'), fixedWidth: 120),
              ],
              rows: const [
                DataRow(
                  cells: [
                    DataCell(Text('1')),
                    DataCell(Text('2')),
                    DataCell(Text('3')),
                    DataCell(Text('4')),
                    DataCell(Text('5')),
                    DataCell(Text('6')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Scrollable), findsWidgets);
  });
}
