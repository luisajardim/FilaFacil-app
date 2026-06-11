import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/main_screen.dart';

class FilaFacilApp extends StatelessWidget {
  const FilaFacilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FilaFácil',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}
