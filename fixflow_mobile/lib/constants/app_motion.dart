import 'package:flutter/material.dart';

abstract class AppMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 160);
  static const Duration slow = Duration(milliseconds: 180);
  static const Curve standardCurve = Curves.easeOutCubic;
}
