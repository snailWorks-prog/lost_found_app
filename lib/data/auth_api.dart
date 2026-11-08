import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';

class AuthApi {
  final String baseUrl;
  final TokenStore tokens;

  AuthApi(this.baseUrl, this.tokens);

  Future<Result<void>> register(
    String email,
    String password,
    String name,
  ) async {
    return _post('/auth/register', {
      'email': email,
      'password': password,
      'name': name,
    });
  }

  Future<Result<void>> login(String email, String password) async {
    return _post('/auth/login', {
      'email': email,
      'password': password,
    });
  }

  Future<void> logout() => tokens.clear();

  Future<Result<void>> _post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: {'content-type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode != 200 && res.statusCode != 201) {
        return Err(apiMessage(res));
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token != null) {
        await tokens.save(token);
      }
      return const Ok(null);
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on FormatException {
      return const Err('Ответ не тот, что обещан');
    } on TypeError {
      return const Err('Ответ не тот, что обещан');
    }
  }
}
