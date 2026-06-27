import '../../domain/models/fila_model.dart';
import '../../domain/models/mesa_model.dart';
import '../../infrastructure/repositories/fila_repository.dart';
import '../../infrastructure/repositories/mesa_repository.dart';

class OperadorService {
  final FilaRepository _filaRepository;
  final MesaRepository _mesaRepository;

  OperadorService({
    FilaRepository? filaRepository,
    MesaRepository? mesaRepository,
  })  : _filaRepository = filaRepository ?? FilaRepository(),
        _mesaRepository = mesaRepository ?? MesaRepository();

  Future<List<FilaModel>> listarFila() => _filaRepository.fetchAll();

  Future<List<MesaModel>> listarMesas() => _mesaRepository.fetchAll();

  Future<FilaModel> chamarCliente(int filaId, int mesaId) =>
      _filaRepository.updateStatus(filaId, status: 'CHAMADO', mesaId: mesaId);

  Future<FilaModel> finalizarAtendimento(int filaId) =>
      _filaRepository.updateStatus(filaId, status: 'ATENDIDO');
}
