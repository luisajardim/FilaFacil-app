import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/fila_model.dart';
import '../providers/fila_provider.dart';
import '../widgets/status_badge_widget.dart';

class ListaFilaScreen extends StatefulWidget {
  const ListaFilaScreen({super.key});

  @override
  State<ListaFilaScreen> createState() => _ListaFilaScreenState();
}

class _ListaFilaScreenState extends State<ListaFilaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FilaProvider>().carregarFila();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FilaProvider>();

    if (!provider.naFila) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.queue_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Você não está na fila.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
            const SizedBox(height: 6),
            const Text('Acesse "Entrar" para entrar na fila.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          ],
        ),
      );
    }

    final minha = provider.minhaEntrada!;
    final outras = provider.fila.where((e) => e.id != minha.id).toList();
    final hora = DateFormat('HH:mm').format(minha.criadoEm.toLocal());

    return RefreshIndicator(
      onRefresh: provider.carregarFila,
      color: AppTheme.primaryOrange,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner "Você foi chamado"
          if (minha.status == FilaStatus.chamado) ...[
            _ChamadoBanner(minha: minha, hora: hora),
            const SizedBox(height: 16),
          ],
          // Card de posição (somente se aguardando)
          if (minha.status == FilaStatus.aguardando) ...[
            _PosicaoCard(provider: provider, minha: minha),
            const SizedBox(height: 16),
          ],
          // Minha solicitação
          _MinhaSolicitacaoCard(minha: minha, hora: hora),
          const SizedBox(height: 20),
          // Outras solicitações
          if (outras.isNotEmpty) ...[
            const Text(
              'OUTRAS SOLICITAÇÕES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            ...outras.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _OutraEntradaRow(entrada: e),
                )),
          ],
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: () => _confirmarSaida(context),
              style: TextButton.styleFrom(foregroundColor: AppTheme.textMuted),
              child: const Text('Sair da fila'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _confirmarSaida(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da fila?'),
        content: const Text('Tem certeza que deseja sair da fila?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Não')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sim, sair'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<FilaProvider>().sairDaFila();
    }
  }
}

// ── Widgets internos ─────────────────────────────────────────────────────────

class _ChamadoBanner extends StatelessWidget {
  final FilaModel minha;
  final String hora;
  const _ChamadoBanner({required this.minha, required this.hora});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppTheme.primaryOrange, AppTheme.lightOrange]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_rounded,
              color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VOCÊ FOI CHAMADO',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  minha.mesa != null
                      ? 'Mesa ${minha.mesa!.id.toString().padLeft(2, '0')} pronta · $hora'
                      : 'Sua vez chegou!',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white70, size: 14),
        ],
      ),
    );
  }
}

class _PosicaoCard extends StatelessWidget {
  final FilaProvider provider;
  final FilaModel minha;
  const _PosicaoCard({required this.provider, required this.minha});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryOrange, AppTheme.lightOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SUA POSIÇÃO',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Colors.greenAccent, size: 7),
                    SizedBox(width: 4),
                    Text(
                      'AO VIVO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${provider.minhaPosicao}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4),
                child: Text(
                  'de ${provider.totalNaFila}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Olá, ${minha.cliente.nome} — vamos te avisar assim que chegar sua vez.',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _MinhaSolicitacaoCard extends StatelessWidget {
  final FilaModel minha;
  final String hora;
  const _MinhaSolicitacaoCard({required this.minha, required this.hora});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SUA SOLICITAÇÃO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.textMuted,
                ),
              ),
              StatusBadgeWidget(status: minha.status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                    icon: Icons.group_outlined,
                    label: 'Pessoas',
                    value: '${minha.quantidadePessoas}'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                    icon: Icons.access_time_rounded,
                    label: 'Entrou às',
                    value: hora),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Nome: ${minha.cliente.nome}',
            style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }
}

class _OutraEntradaRow extends StatelessWidget {
  final FilaModel entrada;
  const _OutraEntradaRow({required this.entrada});

  @override
  Widget build(BuildContext context) {
    final hora = DateFormat('HH:mm').format(entrada.criadoEm.toLocal());
    final pessoasLabel = entrada.quantidadePessoas == 1
        ? '1 pessoa'
        : '${entrada.quantidadePessoas} pessoas';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entrada.cliente.nome,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark)),
              Text('$pessoasLabel · $hora',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textMuted)),
            ],
          ),
        ),
        StatusBadgeWidget(status: entrada.status),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.infoCardBg,
        borderRadius: BorderRadius.circular(10),
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
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
        ],
      ),
    );
  }
}
