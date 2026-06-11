class MesaModel {
  final int id;
  final int capacidade;
  final bool disponivel;

  const MesaModel({
    required this.id,
    required this.capacidade,
    required this.disponivel,
  });

  factory MesaModel.fromJson(Map<String, dynamic> json) => MesaModel(
        id: json['id'] as int,
        capacidade: json['capacidade'] as int,
        // SQLite returns 0/1 integers; PostgreSQL returns booleans
        disponivel: json['disponivel'] == true || json['disponivel'] == 1,
      );
}
