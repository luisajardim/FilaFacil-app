import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/fila_model.dart';
import 'status_badge_widget.dart';

class FilaCardWidget extends StatelessWidget {
  final FilaModel entrada;

  const FilaCardWidget({super.key, required this.entrada});

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
              Text(
                entrada.cliente.nome,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$pessoasLabel · $hora',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        StatusBadgeWidget(status: entrada.status),
      ],
    );
  }
}
