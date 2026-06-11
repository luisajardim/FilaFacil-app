import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/mesa_model.dart';
import '../providers/fila_provider.dart';

class MesasScreen extends StatefulWidget {
  const MesasScreen({super.key});

  @override
  State<MesasScreen> createState() => _MesasScreenState();
}

class _MesasScreenState extends State<MesasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FilaProvider>().carregarMesas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FilaProvider>();
    final mesas = provider.mesas;

    if (provider.mesasLoading && mesas.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryOrange));
    }

    if (mesas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.table_restaurant_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Nenhuma mesa encontrada.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.read<FilaProvider>().carregarMesas(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final livres = mesas.where((m) => m.disponivel).length;
    final ocupadas = mesas.where((m) => !m.disponivel).length;
    final totalCap = mesas.fold(0, (sum, m) => sum + m.capacidade);

    return RefreshIndicator(
      onRefresh: () => context.read<FilaProvider>().carregarMesas(),
      color: AppTheme.primaryOrange,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 8),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estado das mesas',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${mesas.length} mesas · capacidade total de $totalCap lugares',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                          child: _SummaryChip(
                              label: 'Livres',
                              count: livres,
                              isLivre: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _SummaryChip(
                              label: 'Ocupadas',
                              count: ocupadas,
                              isLivre: false)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Grid de mesas
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: mesas.length,
              itemBuilder: (_, i) => _MesaCard(mesa: mesas[i]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isLivre;
  const _SummaryChip(
      {required this.label, required this.count, required this.isLivre});

  @override
  Widget build(BuildContext context) {
    final color =
        isLivre ? AppTheme.statusAtendido : const Color(0xFFF87171);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            '$count',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _MesaCard extends StatelessWidget {
  final MesaModel mesa;
  const _MesaCard({required this.mesa});

  @override
  Widget build(BuildContext context) {
    final isLivre = mesa.disponivel;
    final statusColor =
        isLivre ? AppTheme.statusAtendido : const Color(0xFFF87171);
    final bgColor = isLivre
        ? AppTheme.statusAtendido.withOpacity(0.07)
        : const Color(0xFFFEF2F2);
    final borderColor = isLivre
        ? AppTheme.statusAtendido.withOpacity(0.3)
        : const Color(0xFFFCA5A5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MESA',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: statusColor),
              ),
              Icon(
                isLivre
                    ? Icons.check_circle_outline_rounded
                    : Icons.cancel_outlined,
                color: statusColor,
                size: 18,
              ),
            ],
          ),
          Text(
            mesa.id.toString().padLeft(2, '0'),
            style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: statusColor,
                height: 1.1),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.group_outlined,
                  size: 13, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(
                '${mesa.capacidade} lugares',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isLivre ? 'Livre' : 'Ocupada',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
