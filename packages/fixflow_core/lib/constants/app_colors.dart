import 'package:flutter/material.dart';

abstract class AppStatusColors {
  static const Color open = Color(0xFF22D3EE);
  static const Color inProgress = Color(0xFFF59E0B);
  static const Color completed = Color(0xFF10B981);
  static const Color cancelled = Color(0xFFEF4444);
  static const Color pending = Color(0xFFA78BFA);
  static const Color verified = Color(0xFF22D3EE);
}

abstract class AppCardAccents {
  static const Color requests = Color(0xFF10B981);
  static const Color technicians = Color(0xFF22D3EE);
  static const Color completed = Color(0xFFA78BFA);
  static const Color revenue = Color(0xFFFBBF24);
}

abstract class AppCardGradients {
  static const LinearGradient requests = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF10B981)],
  );

  static const LinearGradient technicians = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0891B2), Color(0xFF22D3EE)],
  );

  static const LinearGradient completed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
  );

  static const LinearGradient revenue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD97706), Color(0xFFFBBF24)],
  );
}

abstract class AppChartColors {
  static const Color primaryLine = Color(0xFFF59E0B);
  static const Color areaFillStart = Color(0x33F59E0B);
  static const Color areaFillEnd = Color(0x00F59E0B);
  static const Color gridLine = Color(0xFF1E293B);
  static const Color axisLabel = Color(0xFF334155);
}