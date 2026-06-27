import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/fila_model.dart';
import '../../domain/models/mesa_model.dart';
import '../providers/operador_provider.dart';
import '../widgets/status_badge_widget.dart';

class FilaOperadorScreen extends StatelessWidget {
  const FilaOperadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OperadorProvider>();

    if (provider.loading && provider.aguardando.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final aguardando = provider.aguardando;

    return RefreshIndicator(
      onRefresh: provider.refresh,
      color: AppTheme.primaryOrange,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _HeaderCard(provider: provider)),
          if (aguardando.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 64, color: Color(0xFFD1D5DB)),
                    SizedBox(height: 16),
                    Text(
                      'Fila vazia',
                      style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Nenhum cliente aguardando no momento.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: aguardando.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _ClienteCard(
                  entrada: aguardando[i],
                  posicao: i + 1,
                  onChamar: () => _mostrarModalMesa(context, aguardando[i]),
                ),
              ),
            ),
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
  final OperadorProvider provider;
  const _HeaderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
          const Text(
            'FILA DE ESPERA',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gerenciar Fila',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${provider.aguardando.length} grupos aguardando · '
            '${provider.mesasLivres.length} mesas livres',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ClienteCard extends StatelessWidget {
  final FilaModel entrada;
  final int posicao;
  final VoidCallback onChamar;

  const _ClienteCard({
    required this.entrada,
    required this.posicao,
    required this.onChamar,
  });

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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$posicao',
                  style: const TextStyle(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
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
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.group_outlined,
                  size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(
                '${entrada.quantidadePessoas} '
                '${entrada.quantidadePessoas == 1 ? 'pessoa' : 'pessoas'}',
                style:
                    const TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded,
                  size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(
                'Chegada: $hora',
                style:
                    const TextStyle(fontSize: 13, color: AppTheme.textMuted),
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
                padding: const EdgeInsets.symmetric(vertical: 14),
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
  MesaModel? _selecionada;
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
              '${widget.entrada.cliente.nome} · '
              'grupo de ${widget.entrada.quantidadePessoas} '
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
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: mesas
                    .map((mesa) => _MesaChip(
                          mesa: mesa,
                          selecionada: _selecionada?.id == mesa.id,
                          onTap: () => setState(() => _selecionada = mesa),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_selecionada == null || _carregando || mesas.isEmpty)
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
    if (_selecionada == null) return;
    setState(() => _carregando = true);
    try {
      await context
          .read<OperadorProvider>()
          .chamarCliente(widget.entrada.id, _selecionada!.id);
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

class _MesaChip extends StatelessWidget {
  final MesaModel mesa;
  final bool selecionada;
  final VoidCallback onTap;

  const _MesaChip({
    required this.mesa,
    required this.selecionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selecionada
              ? AppTheme.primaryOrange
              : AppTheme.primaryOrange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selecionada
                ? AppTheme.primaryOrange
                : AppTheme.primaryOrange.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          'Mesa ${mesa.id.toString().padLeft(2, '0')} · ${mesa.capacidade} lugares',
          style: TextStyle(
            color: selecionada ? Colors.white : AppTheme.primaryOrange,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
