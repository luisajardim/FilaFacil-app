import '../../domain/models/fila_model.dart';
import '../../infrastructure/repositories/fila_repository.dart';

class FilaService {
  final FilaRepository _repository;

  FilaService({FilaRepository? repository})
      : _repository = repository ?? FilaRepository();

  Future<List<FilaModel>> listarFila() => _repository.fetchAll();

  Future<FilaModel> buscarPorId(int id) => _repository.fetchById(id);

  Future<FilaModel> entrarNaFila({
    required String nome,
    required int quantidadePessoas,
  }) {
    if (nome.trim().isEmpty) throw Exception('Informe seu nome.');
    if (quantidadePessoas < 1) throw Exception('Informe ao menos 1 pessoa.');
    return _repository.create(
      nome: nome.trim(),
      quantidadePessoas: quantidadePessoas,
    );
  }
}
