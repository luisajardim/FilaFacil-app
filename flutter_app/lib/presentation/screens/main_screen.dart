import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/fila_model.dart';
import '../providers/fila_provider.dart';
import 'entrar_fila_screen.dart';
import 'lista_fila_screen.dart';
import 'mesas_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const _screens = [
    EntrarFilaScreen(),
    ListaFilaScreen(),
    MesasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FilaProvider>();
    final isChamado = provider.naFila &&
        provider.minhaEntrada?.status == FilaStatus.chamado;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.restaurant_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'RESTAURANTE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    'FilaFácil — Cliente',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.edit_outlined),
            activeIcon: Icon(Icons.edit),
            label: 'Entrar',
          ),
          BottomNavigationBarItem(
            icon: isChamado
                ? Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.format_list_bulleted_outlined),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  )
                : const Icon(Icons.format_list_bulleted_outlined),
            activeIcon: isChamado
                ? Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.format_list_bulleted),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  )
                : const Icon(Icons.format_list_bulleted),
            label: 'Fila',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.table_restaurant_outlined),
            activeIcon: Icon(Icons.table_restaurant),
            label: 'Mesas',
          ),
        ],
      ),
    );
  }
}
