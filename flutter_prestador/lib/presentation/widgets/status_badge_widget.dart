import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/fila_model.dart';

class StatusBadgeWidget extends StatelessWidget {
  final FilaStatus status;

  const StatusBadgeWidget({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      FilaStatus.aguardando => (AppTheme.statusAguardando, const Color(0xFFFEF3C7)),
      FilaStatus.chamado => (AppTheme.statusChamado, const Color(0xFFFEE2E2)),
      FilaStatus.atendido => (AppTheme.statusAtendido, const Color(0xFFDCFCE7)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayLabel.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
