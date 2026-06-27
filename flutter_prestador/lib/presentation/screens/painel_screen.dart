import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/fila_model.dart';
import '../providers/operador_provider.dart';
import '../widgets/status_badge_widget.dart';

class PainelScreen extends StatelessWidget {
  const PainelScreen({super.key});

  String get _saudacao {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia';
    if (h < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OperadorProvider>();

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppTheme.primaryOrange,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(saudacao: _saudacao),
          const SizedBox(height: 16),
          _StatsGrid(provider: provider),
          const SizedBox(height: 20),
          if (provider.proximoDaFila != null) ...[
            const Text(
              'PRÓXIMO DA FILA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            _ProximoCard(
              entrada: provider.proximoDaFila!,
              onChamar: () =>
                  _mostrarModalMesa(context, provider.proximoDaFila!),
            ),
          ],
        ],
      ),
    );
  }

  void _mostrarModalMesa(BuildContext context, FilaModel entrada) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MesaSelecaoModal(entrada: entrada),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String saudacao;
  const _HeaderCard({required this.saudacao});

  @override
  Widget build(BuildContext context) {
    final agora = DateFormat('HH:mm').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Text(
            saudacao.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Painel do Operador',
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Atualizado às $agora',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final OperadorProvider provider;
  const _StatsGrid({required this.provider});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _StatCard(
          icon: Icons.group_outlined,
          valor: '${provider.aguardando.length}',
          label: 'grupos aguardando',
          corIcone: AppTheme.textMuted,
          corValor: AppTheme.textDark,
        ),
        _StatCard(
          icon: Icons.restaurant_outlined,
          valor: '${provider.mesasLivres.length}',
          label: 'disponíveis agora',
          corIcone: AppTheme.textMuted,
          corValor: AppTheme.textDark,
        ),
        _StatCard(
          icon: Icons.notifications_outlined,
          valor: '${provider.chamados.length}',
          label: 'aguardando mesa',
          corIcone: AppTheme.statusChamado,
          corValor: AppTheme.statusChamado,
        ),
        _StatCard(
          icon: Icons.check_circle_outline_rounded,
          valor: '${provider.totalAtendidos}',
          label: 'grupos atendidos',
          corIcone: AppTheme.primaryOrange,
          corValor: AppTheme.primaryOrange,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String valor;
  final String label;
  final Color corIcone;
  final Color corValor;

  const _StatCard({
    required this.icon,
    required this.valor,
    required this.label,
    required this.corIcone,
    required this.corValor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: corIcone, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valor,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: corValor,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProximoCard extends StatelessWidget {
  final FilaModel entrada;
  final VoidCallback onChamar;

  const _ProximoCard({required this.entrada, required this.onChamar});

  @override
  Widget build(BuildContext context) {
    final hora = DateFormat('HH:mm').format(entrada.criadoEm.toLocal());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '1',
                  style: TextStyle(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entrada.cliente.nome,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              StatusBadgeWidget(status: entrada.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.group_outlined,
                  size: 13, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(
                '${entrada.quantidadePessoas} '
                '${entrada.quantidadePessoas == 1 ? 'pessoa' : 'pessoas'}',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.access_time_rounded,
                  size: 13, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(
                'Chegada: $hora',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onChamar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Chamar para mesa',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MesaSelecaoModal extends StatefulWidget {
  final FilaModel entrada;
  const _MesaSelecaoModal({required this.entrada});

  @override
  State<_MesaSelecaoModal> createState() => _MesaSelecaoModalState();
}

class _MesaSelecaoModalState extends State<_MesaSelecaoModal> {
  int? _mesaSelecionadaId;
  bool _carregando = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OperadorProvider>();
    final mesas = provider.mesasCompativeis(widget.entrada.quantidadePessoas);

    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Alocar para mesa',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.entrada.cliente.nome} · grupo de '
              '${widget.entrada.quantidadePessoas} '
              '${widget.entrada.quantidadePessoas == 1 ? 'pessoa' : 'pessoas'}',
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 20),
            const Text(
              'SELECIONE UMA MESA LIVRE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            if (mesas.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Nenhuma mesa disponível para este grupo.',
                  style:
                      TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: mesas
                    .map((m) => GestureDetector(
                          onTap: () =>
                              setState(() => _mesaSelecionadaId = m.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: _mesaSelecionadaId == m.id
                                  ? AppTheme.primaryOrange
                                  : AppTheme.primaryOrange
                                      .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _mesaSelecionadaId == m.id
                                    ? AppTheme.primaryOrange
                                    : AppTheme.primaryOrange
                                        .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              'Mesa ${m.id.toString().padLeft(2, '0')} · ${m.capacidade} lugares',
                              style: TextStyle(
                                color: _mesaSelecionadaId == m.id
                                    ? Colors.white
                                    : AppTheme.primaryOrange,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_mesaSelecionadaId == null ||
                        _carregando ||
                        mesas.isEmpty)
                    ? null
                    : () => _confirmar(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  disabledBackgroundColor: const Color(0xFFD1D5DB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _carregando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Confirmar alocação',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmar(BuildContext context) async {
    if (_mesaSelecionadaId == null) return;
    setState(() => _carregando = true);
    try {
      await context
          .read<OperadorProvider>()
          .chamarCliente(widget.entrada.id, _mesaSelecionadaId!);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppTheme.statusChamado,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }
}
