import 'dart:convert';
import 'package:http/http.dart' as http;

String apiMessage(http.Response res) {
  try {
    final data = jsonDecode(res.body);
    if (data is Map<String, dynamic> && data['error'] is Map<String, dynamic>) {
      final code = data['error']['code'] as String?;
      switch (code) {
        case 'VALIDATION_ERROR':
          return 'Отправленные данные недействительны';
        case 'UNAUTHORIZED':
          return 'Неверный email или пароль';
        case 'EMAIL_TAKEN':
          return 'Аккаунт с этим email уже существует';
        case 'NOT_FOUND':
          return 'Запись не существует';
        default:
          return 'Ошибка сервера ($code)';
      }
    }
  } catch (_) {}
  return 'Ошибка сервера (${res.statusCode})';
}
