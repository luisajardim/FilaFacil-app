import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../domain/models/mesa_model.dart';

class MesaRepository {
  final http.Client _client;

  MesaRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<MesaModel>> fetchAll() async {
    final response = await _client
        .get(Uri.parse('${ApiConstants.baseUrl}${ApiConstants.mesa}'))
        .timeout(const Duration(seconds: 10));
    _assertOk(response);
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => MesaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void _assertOk(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Erro ao carregar mesas (${response.statusCode})');
    }
  }
}
