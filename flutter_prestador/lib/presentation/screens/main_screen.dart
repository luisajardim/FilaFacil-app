import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'fila_operador_screen.dart';
import 'mesas_operador_screen.dart';
import 'painel_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _tabIndex = 0;

  static const _telas = [
    FilaOperadorScreen(),
    MesasOperadorScreen(),
    PainelScreen(),
  ];

  static const _labels = ['Fila', 'Mesas', 'Painel'];

  static const _icons = [
    Icons.format_list_bulleted_rounded,
    Icons.table_restaurant_outlined,
    Icons.dashboard_outlined,
  ];

  static const _iconsAtivos = [
    Icons.format_list_bulleted_rounded,
    Icons.table_restaurant_rounded,
    Icons.dashboard_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: const Text(
                'FF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'FilaFácil · Operador',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
      body: _telas[_tabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        items: List.generate(
          _labels.length,
          (i) => BottomNavigationBarItem(
            icon: Icon(_icons[i]),
            activeIcon: Icon(_iconsAtivos[i]),
            label: _labels[i],
          ),
        ),
      ),
    );
  }
}
