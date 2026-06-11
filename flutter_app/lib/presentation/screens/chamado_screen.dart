import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/fila_model.dart';
import '../providers/fila_provider.dart';
import '../widgets/status_badge_widget.dart';

class ChamadoScreen extends StatelessWidget {
  const ChamadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FilaProvider>();

    if (!provider.naFila) {
      return _buildEmpty(
        icon: Icons.notifications_none_rounded,
        title: 'Você não está na fila.',
        subtitle: 'Acesse "Entrar" para entrar na fila.',
      );
    }

    final minha = provider.minhaEntrada!;
    return switch (minha.status) {
      FilaStatus.aguardando => _AguardandoView(
          minha: minha,
          posicao: provider.minhaPosicao,
          total: provider.totalNaFila,
        ),
      FilaStatus.chamado => _ChamadoView(minha: minha),
      FilaStatus.atendido => _AtendidoView(minha: minha),
    };
  }

  static Widget _buildEmpty(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: const Color(0xFFD1D5DB)),
          const SizedBox(height: 16),
          Text(title,
              style:
                  const TextStyle(color: AppTheme.textMuted, fontSize: 16)),
          const SizedBox(height: 6),
          Text(subtitle,
              style:
                  const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Aguardando ────────────────────────────────────────────────────────────────

class _AguardandoView extends StatelessWidget {
  final FilaModel minha;
  final int posicao;
  final int total;
  const _AguardandoView(
      {required this.minha, required this.posicao, required this.total});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.statusAguardando.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hourglass_top_rounded,
                  size: 52, color: AppTheme.statusAguardando),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aguardando sua vez...',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Olá, ${minha.cliente.nome}! Vamos te avisar quando sua mesa estiver pronta.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, color: Colors.green, size: 8),
                  const SizedBox(width: 8),
                  Text(
                    'Posição $posicao de $total na fila',
                    style: const TextStyle(
                      color: AppTheme.primaryOrange,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chamado ───────────────────────────────────────────────────────────────────

class _ChamadoView extends StatelessWidget {
  final FilaModel minha;
  const _ChamadoView({required this.minha});

  @override
  Widget build(BuildContext context) {
    final hora = DateFormat('HH:mm').format(minha.criadoEm.toLocal());
    final mesa = minha.mesa;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Banner principal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.primaryOrange, AppTheme.lightOrange]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.white,
                          size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '● SUA VEZ CHEGOU',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text('Olá, ${minha.cliente.nome}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14)),
                const Text(
                  'Sua mesa está pronta!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Dirija-se ao salão e procure pelo número abaixo.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Mesa designada
          if (mesa != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 8),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'MESA DESIGNADA',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'MESA',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryOrange,
                              letterSpacing: 1),
                        ),
                        Text(
                          mesa.id.toString().padLeft(2, '0'),
                          style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryOrange,
                              height: 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.group_outlined,
                          size: 15, color: AppTheme.textMuted),
                      const SizedBox(width: 6),
                      Text('Capacidade para ${mesa.capacidade} pessoas',
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Tiles de info
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                    icon: Icons.access_time_rounded,
                    label: 'Chamado às',
                    value: hora),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                    icon: Icons.group_outlined,
                    label: 'Pessoas',
                    value: '${minha.quantidadePessoas}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Como chegar
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_outlined,
                      color: AppTheme.primaryOrange, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Como chegar',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark)),
                      SizedBox(height: 4),
                      Text(
                        'Procure o(a) recepcionista informando seu nome. A mesa fica reservada por 5 minutos a partir da chamada.',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Botão confirmar chegada
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _confirmarChegada(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFF0D0),
                foregroundColor: const Color(0xFFC05000),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Confirmar chegada',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _confirmarChegada(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar chegada'),
        content: const Text(
            'Ao confirmar, sua solicitação será marcada como concluída.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<FilaProvider>().sairDaFila();
    }
  }
}

// ── Atendido ──────────────────────────────────────────────────────────────────

class _AtendidoView extends StatelessWidget {
  final FilaModel minha;
  const _AtendidoView({required this.minha});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.statusAtendido.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  size: 52, color: AppTheme.statusAtendido),
            ),
            const SizedBox(height: 24),
            const Text(
              'Você está sendo atendido!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Bom apetite, ${minha.cliente.nome}!\nAproveite sua refeição.',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info tile ─────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 13, color: AppTheme.textMuted),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textMuted)),
          ]),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
        ],
      ),
    );
  }
}
