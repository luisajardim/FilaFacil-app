import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/fila_model.dart';
import '../../domain/models/mesa_model.dart';
import '../providers/operador_provider.dart';

class MesasOperadorScreen extends StatelessWidget {
  const MesasOperadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OperadorProvider>();
    final mesas = provider.mesas;
    final capacidadeTotal = mesas.fold(0, (sum, m) => sum + m.capacidade);

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppTheme.primaryOrange,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estado das mesas',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${mesas.length} mesas · capacidade total de $capacidadeTotal lugares',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          valor: provider.mesasLivres.length,
                          label: 'Livres',
                          cor: AppTheme.statusAtendido,
                          bg: const Color(0xFFDCFCE7),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          valor: provider.mesasOcupadas.length,
                          label: 'Ocupadas',
                          cor: AppTheme.statusChamado,
                          bg: const Color(0xFFFEE2E2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _MesaCard(
                  mesa: mesas[i],
                  filaAtiva: provider.chamados
                      .where((e) => e.mesa?.id == mesas[i].id)
                      .firstOrNull,
                  onLiberar: () =>
                      _confirmarLiberacao(context, provider, mesas[i]),
                ),
                childCount: mesas.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarLiberacao(
    BuildContext context,
    OperadorProvider provider,
    MesaModel mesa,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Liberar mesa?'),
        content: Text(
            'Marcar o atendimento da Mesa ${mesa.id.toString().padLeft(2, '0')} como concluído?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white),
            child: const Text('Liberar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await provider.liberarMesa(mesa.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: AppTheme.statusChamado,
            ),
          );
        }
      }
    }
  }
}

class _StatBox extends StatelessWidget {
  final int valor;
  final String label;
  final Color cor;
  final Color bg;

  const _StatBox({
    required this.valor,
    required this.label,
    required this.cor,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$valor',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: cor,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 13, color: cor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _MesaCard extends StatelessWidget {
  final MesaModel mesa;
  final FilaModel? filaAtiva;
  final VoidCallback onLiberar;

  const _MesaCard({
    required this.mesa,
    required this.filaAtiva,
    required this.onLiberar,
  });

  @override
  Widget build(BuildContext context) {
    final livre = mesa.disponivel;
    final corStatus = livre ? AppTheme.statusAtendido : AppTheme.statusChamado;
    final bgStatus =
        livre ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: livre
              ? AppTheme.statusAtendido.withValues(alpha: 0.3)
              : AppTheme.statusChamado.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                livre ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: corStatus,
                size: 20,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bgStatus,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  livre ? 'LIVRE' : 'OCUPADA',
                  style: TextStyle(
                    color: corStatus,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'MESA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          Text(
            mesa.id.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: corStatus,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.group_outlined,
                  size: 12, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(
                '${mesa.capacidade} lugares',
                style:
                    const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
          if (!livre) ...[
            if (filaAtiva != null) ...[
              const SizedBox(height: 6),
              Text(
                filaAtiva!.cliente.nome,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onLiberar,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.statusChamado,
                  side: BorderSide(
                      color: AppTheme.statusChamado.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Liberar mesa',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ] else
            const Spacer(),
        ],
      ),
    );
  }
}
