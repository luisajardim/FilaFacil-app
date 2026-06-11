import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/fila_model.dart';

class StatusBadgeWidget extends StatelessWidget {
  final FilaStatus status;

  const StatusBadgeWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      FilaStatus.aguardando => (
          'Aguardando',
          AppTheme.statusAguardando,
          Icons.hourglass_empty_rounded,
        ),
      FilaStatus.chamado => (
          'Chamado',
          AppTheme.statusChamado,
          Icons.notifications_active_rounded,
        ),
      FilaStatus.atendido => (
          'Em atendimento',
          AppTheme.statusAtendido,
          Icons.restaurant_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
