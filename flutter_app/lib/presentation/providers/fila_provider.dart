import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../application/services/fila_service.dart';
import '../../application/services/notification_service.dart';
import '../../domain/models/fila_model.dart';
import '../../domain/models/mesa_model.dart';
import '../../infrastructure/repositories/mesa_repository.dart';

class FilaProvider extends ChangeNotifier {
  final FilaService _filaService;
  final MesaRepository _mesaRepository;
  final NotificationService _notificationService;

  List<FilaModel> _fila = [];
  List<MesaModel> _mesas = [];
  FilaModel? _minhaEntrada;
  bool _loading = false;
  bool _mesasLoading = false;
  String? _error;

  List<FilaModel> get fila => _fila;
  List<MesaModel> get mesas => _mesas;
  FilaModel? get minhaEntrada => _minhaEntrada;
  bool get loading => _loading;
  bool get mesasLoading => _mesasLoading;
  String? get error => _error;
  bool get naFila => _minhaEntrada != null;

  int get minhaPosicao {
    if (_minhaEntrada == null) return 0;
    final aguardando =
        _fila.where((e) => e.status == FilaStatus.aguardando).toList();
    final idx = aguardando.indexWhere((e) => e.id == _minhaEntrada!.id);
    return idx == -1 ? 0 : idx + 1;
  }

  int get totalNaFila =>
      _fila.where((e) => e.status == FilaStatus.aguardando).length;

  FilaProvider({
    FilaService? filaService,
    MesaRepository? mesaRepository,
    NotificationService? notificationService,
  })  : _filaService = filaService ?? FilaService(),
        _mesaRepository = mesaRepository ?? MesaRepository(),
        _notificationService = notificationService ?? NotificationService() {
    _init();
  }

  Future<void> _init() async {
    try {
      await _loadMinhaEntrada();
      await carregarFila();
      if (_minhaEntrada != null) _startPolling();
    } catch (_) {}
  }

  Future<void> _loadMinhaEntrada() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('minha_fila_id');
    if (id == null) return;
    try {
      _minhaEntrada = await _filaService.buscarPorId(id);
    } catch (_) {
      await prefs.remove('minha_fila_id');
    }
  }

  Future<void> carregarFila() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _fila = await _filaService.listarFila();
      if (_minhaEntrada != null) {
        final match = _fila.where((e) => e.id == _minhaEntrada!.id);
        if (match.isNotEmpty) _minhaEntrada = match.first;
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> carregarMesas() async {
    _mesasLoading = true;
    notifyListeners();
    try {
      _mesas = await _mesaRepository.fetchAll();
    } catch (_) {}
    _mesasLoading = false;
    notifyListeners();
  }

  Future<void> entrarNaFila({
    required String nome,
    required int quantidadePessoas,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final entrada = await _filaService.entrarNaFila(
        nome: nome,
        quantidadePessoas: quantidadePessoas,
      );
      _minhaEntrada = entrada;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('minha_fila_id', entrada.id);
      await carregarFila();
      _startPolling();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> sairDaFila() async {
    _notificationService.stopPolling();
    _minhaEntrada = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('minha_fila_id');
    notifyListeners();
  }

  void _startPolling() {
    if (_minhaEntrada == null) return;
    _notificationService.startPolling(_minhaEntrada!.id, (updated) {
      _minhaEntrada = updated;
      final idx = _fila.indexWhere((e) => e.id == updated.id);
      if (idx != -1) _fila[idx] = updated;
      notifyListeners();
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationService.stopPolling();
    super.dispose();
  }
}
