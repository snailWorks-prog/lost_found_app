import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'lost_found_repository.dart';
import 'models.dart';
import 'result.dart';
import 'token_store.dart';

class HttpLostFoundRepository implements LostFoundRepository {
  final String baseUrl;
  final TokenStore tokens;
  final void Function()? onUnauthorized;

  HttpLostFoundRepository(
    this.baseUrl,
    this.tokens, {
    this.onUnauthorized,
  });

  Future<Map<String, String>> _headers() async {
    final token = await tokens.read() ?? '';
    return {
      'content-type': 'application/json',
      'authorization': 'Bearer $token',
    };
  }

  Future<Err<T>> _sessionDied<T>() async {
    await tokens.clear();
    onUnauthorized?.call();
    return const Err('Сессия истекла — войдите снова');
  }

  @override
  Future<Result<List<CampusItem>>> fetchItems({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/items').replace(queryParameters: {
        'page': '$page',
        'limit': '$limit',
        if (search != null && search.isNotEmpty) 'search': search,
      });

      final res = await http
          .get(
            uri,
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 401) return _sessionDied();
      if (res.statusCode != 200) return Err(apiMessage(res));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final rawList = (data['items'] as List?) ?? [];
      final items = rawList
          .map((e) => CampusItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return Ok(items);
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

  @override
  Future<Result<CampusItem>> fetchItemById(String id) async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/items/$id'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 401) return _sessionDied();
      if (res.statusCode != 200) return Err(apiMessage(res));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return Ok(CampusItem.fromJson(data));
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

  @override
  Future<Result<CampusItem>> createItem(CampusItem draft) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/items'),
            headers: await _headers(),
            body: jsonEncode(draft.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 401) return _sessionDied();
      if (res.statusCode != 201 && res.statusCode != 200) {
        return Err(apiMessage(res));
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return Ok(CampusItem.fromJson(data));
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

  @override
  Future<Result<CampusItem>> updateItem(CampusItem item) async {
    try {
      final res = await http
          .put(
            Uri.parse('$baseUrl/items/${item.id}'),
            headers: await _headers(),
            body: jsonEncode(item.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 401) return _sessionDied();
      if (res.statusCode != 200) return Err(apiMessage(res));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return Ok(CampusItem.fromJson(data));
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

  @override
  Future<Result<void>> deleteItem(String id) async {
    try {
      final res = await http
          .delete(
            Uri.parse('$baseUrl/items/$id'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 401) return _sessionDied();
      if (res.statusCode != 204 && res.statusCode != 200) {
        return Err(apiMessage(res));
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

  @override
  Future<Result<List<CampusClaim>>> fetchClaims() async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/claims'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 401) return _sessionDied();
      if (res.statusCode != 200) return Err(apiMessage(res));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final rawList = (data['items'] as List?) ?? [];
      final claims = rawList
          .map((e) => CampusClaim.fromJson(e as Map<String, dynamic>))
          .toList();
      return Ok(claims);
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

  @override
  Future<Result<CampusClaim>> createClaim(CampusClaim draft) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/claims'),
            headers: await _headers(),
            body: jsonEncode(draft.toJson()),
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 401) return _sessionDied();
      if (res.statusCode != 201 && res.statusCode != 200) {
        return Err(apiMessage(res));
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return Ok(CampusClaim.fromJson(data));
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

  @override
  Future<Result<void>> deleteClaim(String id) async {
    try {
      final res = await http
          .delete(
            Uri.parse('$baseUrl/claims/$id'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 401) return _sessionDied();
      if (res.statusCode != 204 && res.statusCode != 200) {
        return Err(apiMessage(res));
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

  @override
  Future<Result<List<ChatMessage>>> fetchMessages(String claimId) async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/claims/$claimId/messages'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 401) return _sessionDied();
      if (res.statusCode != 200) return Err(apiMessage(res));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final rawList = (data['items'] as List?) ?? [];
      final messages = rawList
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      return Ok(messages);
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

  @override
  Future<Result<ChatMessage>> sendMessage(String claimId, String text) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/claims/$claimId/messages'),
            headers: await _headers(),
            body: jsonEncode({'text': text}),
          )
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 401) return _sessionDied();
      if (res.statusCode != 201 && res.statusCode != 200) {
        return Err(apiMessage(res));
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return Ok(ChatMessage.fromJson(data));
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
