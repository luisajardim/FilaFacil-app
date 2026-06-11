class ClienteModel {
  final int id;
  final String nome;

  const ClienteModel({required this.id, required this.nome});

  factory ClienteModel.fromJson(Map<String, dynamic> json) => ClienteModel(
        id: json['id'] as int,
        nome: json['nome'] as String,
      );
}
