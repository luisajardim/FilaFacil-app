import 'cliente_model.dart';
import 'mesa_model.dart';

enum FilaStatus {
  aguardando('AGUARDANDO'),
  chamado('CHAMADO'),
  atendido('ATENDIDO');

  final String value;
  const FilaStatus(this.value);

  String get displayLabel => switch (this) {
        FilaStatus.aguardando => 'Aguardando',
        FilaStatus.chamado => 'Chamado',
        FilaStatus.atendido => 'Em atendimento',
      };

  static FilaStatus fromString(String s) => FilaStatus.values.firstWhere(
        (e) => e.value == s.toUpperCase(),
        orElse: () => FilaStatus.aguardando,
      );
}

class FilaModel {
  final int id;
  final ClienteModel cliente;
  final int quantidadePessoas;
  final FilaStatus status;
  final MesaModel? mesa;
  final DateTime criadoEm;

  const FilaModel({
    required this.id,
    required this.cliente,
    required this.quantidadePessoas,
    required this.status,
    this.mesa,
    required this.criadoEm,
  });

  factory FilaModel.fromJson(Map<String, dynamic> json) => FilaModel(
        id: json['id'] as int,
        cliente: ClienteModel.fromJson(json['cliente'] as Map<String, dynamic>),
        quantidadePessoas: json['quantidade_pessoas'] as int,
        status: FilaStatus.fromString(json['status'] as String),
        mesa: json['mesa'] != null
            ? MesaModel.fromJson(json['mesa'] as Map<String, dynamic>)
            : null,
        criadoEm: DateTime.parse(json['criado_em'] as String),
      );
}
