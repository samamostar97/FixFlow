import 'dart:math' as math;

import 'package:data_table_2/data_table_2.dart';
import 'package:fixflow_desktop/constants/app_density.dart';
import 'package:flutter/material.dart';

class AppDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double? minWidth;
  final int fixedTopRows;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.minWidth,
    this.fixedTopRows = 1,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveMinWidth = math.max(
          constraints.maxWidth,
          minWidth ?? constraints.maxWidth,
        );

        return _buildTableContainer(cs, effectiveMinWidth);
      },
    );
  }

  Widget _buildTableContainer(ColorScheme cs, double effectiveMinWidth) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: DataTable2(
        minWidth: effectiveMinWidth,
        fixedTopRows: fixedTopRows,
        headingRowHeight: AppDensity.tableHeadingHeight,
        dataRowHeight: AppDensity.tableRowHeight,
        horizontalMargin: 14,
        columnSpacing: 14,
        dividerThickness: 1,
        bottomMargin: 0,
        showCheckboxColumn: false,
        headingRowColor: WidgetStatePropertyAll(
          cs.surfaceContainerLow.withValues(alpha: 0.9),
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return cs.surfaceContainerLow.withValues(alpha: 0.35);
          }
          return Colors.transparent;
        }),
        columns: columns,
        rows: rows,
      ),
    );
  }
}
