import 'package:fixflow_mobile/config/router.dart';
import 'package:fixflow_mobile/constants/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: FixFlowMobileApp()));
}

class FixFlowMobileApp extends StatelessWidget {
  const FixFlowMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixFlow',
      debugShowCheckedModeBanner: false,
      theme: darkTheme(),
      home: const AppRouter(),
    );
  }
}
