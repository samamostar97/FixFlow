import 'package:flutter/material.dart';

class EnumHelper {
  static String getDisplayName(Enum value) {
    final name = value.name;
    return name.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => ' ${match.group(0)}',
    ).trim();
  }

  static List<DropdownMenuItem<T>> toDropdownItems<T extends Enum>(
    List<T> values,
    String Function(T) displayName,
  ) {
    return values
        .map((e) => DropdownMenuItem(value: e, child: Text(displayName(e))))
        .toList();
  }
}
