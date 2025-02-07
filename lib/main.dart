import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/stories/stories_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HN Roasted',
      theme: AppTheme.light,
      home: const StoriesPage(),
    );
  }
}
