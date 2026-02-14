import 'package:flutter/material.dart';
import 'package:fixflow_desktop/constants/app_density.dart';

ThemeData darkTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'Inter',
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF0C1222),
    surfaceContainerHighest: Color(0xFF0F1829),
    surfaceContainerHigh: Color(0xFF080E1A),
    surfaceContainerLow: Color(0xFF1E293B),
    primary: Color(0xFF22D3EE),
    onPrimary: Color(0xFF0C1222),
    secondary: Color(0xFF7C3AED),
    onSecondary: Colors.white,
    tertiary: Color(0xFF10B981),
    onSurface: Color(0xFFE2E8F0),
    onSurfaceVariant: Color(0xFF94A3B8),
    inverseSurface: Color(0xFF475569),
    error: Color(0xFFEF4444),
    outline: Color(0xFF1E293B),
    outlineVariant: Color(0xFF334155),
  ),
  scaffoldBackgroundColor: const Color(0xFF0C1222),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: const Color(0xFF0F1829),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFF1E293B)),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      elevation: 0,
      minimumSize: const Size(0, AppDensity.inputHeight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: Color(0xFF334155)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    constraints: const BoxConstraints(minHeight: AppDensity.inputHeight),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF1E293B)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF1E293B)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF22D3EE)),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    filled: true,
    fillColor: const Color(0xFF0F1829),
  ),
  dividerTheme: const DividerThemeData(
    thickness: 1,
    space: 1,
    color: Color(0xFF1E293B),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: const Color(0xFF0F1829),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFF1E293B)),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  dropdownMenuTheme: const DropdownMenuThemeData(
    menuStyle: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(Color(0xFF0F1829)),
    ),
  ),
  popupMenuTheme: const PopupMenuThemeData(color: Color(0xFF0F1829)),
  dataTableTheme: DataTableThemeData(
    headingRowColor: const WidgetStatePropertyAll(Color(0xFF1E293B)),
    headingTextStyle: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: Color(0xFF94A3B8),
    ),
    dataTextStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: Color(0xFFE2E8F0),
    ),
    headingRowHeight: AppDensity.tableHeadingHeight,
    dataRowMinHeight: AppDensity.tableRowHeight,
    dataRowMaxHeight: AppDensity.tableRowHeight,
    dataRowColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.hovered)) {
        return const Color(0xFF1E293B).withValues(alpha: 0.55);
      }
      return Colors.transparent;
    }),
    dividerThickness: 1,
  ),
);
