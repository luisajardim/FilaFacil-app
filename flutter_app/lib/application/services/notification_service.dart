import 'dart:async';

import '../../core/constants/api_constants.dart';
import '../../domain/models/fila_model.dart';
import '../../infrastructure/repositories/fila_repository.dart';

typedef StatusCallback = void Function(FilaModel entrada);

class NotificationService {
  final FilaRepository _repository;
  Timer? _timer;

  NotificationService({FilaRepository? repository})
      : _repository = repository ?? FilaRepository();

  void startPolling(int filaId, StatusCallback onUpdate) {
    _timer?.cancel();
    _timer = Timer.periodic(ApiConstants.pollingInterval, (_) async {
      try {
        final updated = await _repository.fetchById(filaId);
        onUpdate(updated);
      } catch (_) {
        // Silently ignore transient network errors during polling
      }
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }
}
