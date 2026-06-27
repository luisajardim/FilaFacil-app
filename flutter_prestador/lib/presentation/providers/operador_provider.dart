import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../application/services/operador_service.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/models/fila_model.dart';
import '../../domain/models/mesa_model.dart';

class OperadorProvider extends ChangeNotifier {
  final OperadorService _service;

  List<FilaModel> _fila = [];
  List<MesaModel> _mesas = [];
  bool _loading = false;
  String? _error;
  Timer? _timer;

  List<FilaModel> get fila => _fila;
  List<MesaModel> get mesas => _mesas;
  bool get loading => _loading;
  String? get error => _error;

  List<FilaModel> get aguardando =>
      _fila.where((e) => e.status == FilaStatus.aguardando).toList();

  List<FilaModel> get chamados =>
      _fila.where((e) => e.status == FilaStatus.chamado).toList();

  int get totalAtendidos =>
      _fila.where((e) => e.status == FilaStatus.atendido).length;

  List<MesaModel> get mesasLivres =>
      _mesas.where((m) => m.disponivel).toList();

  List<MesaModel> get mesasOcupadas =>
      _mesas.where((m) => !m.disponivel).toList();

  int get capacidadeTotalMesas =>
      _mesas.fold(0, (sum, m) => sum + m.capacidade);

  FilaModel? get proximoDaFila =>
      aguardando.isNotEmpty ? aguardando.first : null;

  List<MesaModel> mesasCompativeis(int quantidadePessoas) => _mesas
      .where((m) => m.disponivel && m.capacidade >= quantidadePessoas)
      .toList();

  OperadorProvider({OperadorService? service})
      : _service = service ?? OperadorService() {
    _init();
  }

  Future<void> _init() async {
    await refresh();
    _startPolling();
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(ApiConstants.pollingInterval, (_) => _silentRefresh());
  }

  Future<void> _silentRefresh() async {
    try {
      final results = await Future.wait([
        _service.listarFila(),
        _service.listarMesas(),
      ]);
      _fila = results[0] as List<FilaModel>;
      _mesas = results[1] as List<MesaModel>;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.listarFila(),
        _service.listarMesas(),
      ]);
      _fila = results[0] as List<FilaModel>;
      _mesas = results[1] as List<MesaModel>;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> chamarCliente(int filaId, int mesaId) async {
    await _service.chamarCliente(filaId, mesaId);
    await _silentRefresh();
  }

  // Libera a mesa marcando a entrada CHAMADO correspondente como ATENDIDO.
  // O backend automaticamente marca mesa.disponivel = true na transição ATENDIDO.
  Future<void> liberarMesa(int mesaId) async {
    final entrada = _fila.firstWhere(
      (e) => e.mesa?.id == mesaId && e.status == FilaStatus.chamado,
      orElse: () => throw Exception('Nenhuma entrada ativa para esta mesa.'),
    );
    await _service.finalizarAtendimento(entrada.id);
    await _silentRefresh();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
