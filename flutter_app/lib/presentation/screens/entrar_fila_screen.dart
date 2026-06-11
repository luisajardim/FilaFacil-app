import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/fila_model.dart';
import '../providers/fila_provider.dart';
import '../widgets/formulario_entrada_widget.dart';

class EntrarFilaScreen extends StatelessWidget {
  const EntrarFilaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FilaProvider>();
    return provider.naFila
        ? _JaNaFilaView(provider: provider)
        : _FormularioView(provider: provider);
  }
}

// ── Formulário ──────────────────────────────────────────────────────────────

class _FormularioView extends StatelessWidget {
  final FilaProvider provider;
  const _FormularioView({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Banner de boas-vindas
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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
                  'BEM-VINDO',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Entre na fila sem\nsair da sua mesa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.loading
                      ? 'Carregando...'
                      : '${provider.totalNaFila} '
                          '${provider.totalNaFila == 1 ? 'pessoa aguardando' : 'pessoas aguardando'} agora.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Formulário
          FormularioEntradaWidget(
            loading: provider.loading,
            onSubmit: (nome, qtd) async {
              await provider.entrarNaFila(
                  nome: nome, quantidadePessoas: qtd);
              if (provider.error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.error!),
                    backgroundColor: Colors.red.shade600,
                  ),
                );
                provider.clearError();
              }
            },
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Seus dados são usados apenas para gerenciar sua posição na fila.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Já na fila ───────────────────────────────────────────────────────────────

class _JaNaFilaView extends StatelessWidget {
  final FilaProvider provider;
  const _JaNaFilaView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final entrada = provider.minhaEntrada!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Banner de status
          Container(
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
                const Text(
                  'VOCÊ JÁ ESTÁ NA FILA',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Olá, ${entrada.cliente.nome}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: ${entrada.status.displayLabel}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Acesse a aba "Fila" para ver sua posição\nou "Chamado" para detalhes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _confirmarSaida(context),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade600),
                  child: const Text('Sair da fila'),
                ),
              ],
            ),
          ),
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
            child: const Text('Não'),
          ),
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
