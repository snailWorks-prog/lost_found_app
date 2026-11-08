import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';

class FileApi {
  final String baseUrl;
  final TokenStore tokens;

  FileApi(this.baseUrl, this.tokens);

  Future<Result<String>> uploadBytes(List<int> bytes, String filename) async {
    try {
      final uri = Uri.parse('$baseUrl/files');
      final request = http.MultipartRequest('POST', uri);

      final token = await tokens.read() ?? '';
      request.headers['authorization'] = 'Bearer $token';

      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      );
      request.files.add(multipartFile);

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 20));
      final res = await http.Response.fromStream(streamedResponse);

      if (res.statusCode == 401) {
        await tokens.clear();
        return const Err('Сессия истекла — войдите снова');
      }

      if (res.statusCode != 201 && res.statusCode != 200) {
        return Err(apiMessage(res));
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final url = data['url'] as String?;
      if (url == null) return const Err('Ответ не тот, что обещан');
      return Ok(url);
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

  Future<Result<String>> uploadFile(String path) async {
    final file = File(path);
    if (!file.existsSync()) return const Err('Файл не найден');
    final bytes = await file.readAsBytes();
    final filename = path.split(Platform.pathSeparator).last;
    return uploadBytes(bytes, filename);
  }
}
