import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/main_screen.dart';

class FilaFacilOperadorApp extends StatelessWidget {
  const FilaFacilOperadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FilaFácil · Operador',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}
