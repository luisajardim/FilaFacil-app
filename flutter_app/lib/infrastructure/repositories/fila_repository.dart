import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../domain/models/fila_model.dart';

class FilaRepository {
  final http.Client _client;

  FilaRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<FilaModel>> fetchAll() async {
    final response = await _client
        .get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.fila}'))
        .timeout(const Duration(seconds: 10));
    _assertOk(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => FilaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FilaModel> fetchById(int id) async {
    final response = await _client
        .get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.fila}/$id'))
        .timeout(const Duration(seconds: 10));
    _assertOk(response);
    return FilaModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<FilaModel> create(
      {required String nome, required int quantidadePessoas}) async {
    final response = await _client
        .post(
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.fila}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(
              {'nome': nome, 'quantidade_pessoas': quantidadePessoas}),
        )
        .timeout(const Duration(seconds: 10));
    _assertOk(response);
    return FilaModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  void _assertOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Erro na requisição (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        message = (decoded['erro'] ?? decoded['message'] ?? message) as String;
      } catch (_) {}
      throw Exception(message);
    }
  }
}
