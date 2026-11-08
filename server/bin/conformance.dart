// Conformance test suite for PAM backend (37 checks).
//
// Usage: dart run bin/conformance.dart [--base-url http://localhost:8080]

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

Future<void> main(List<String> args) async {
  var baseUrl = 'http://localhost:8080';
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--base-url' && i + 1 < args.length) {
      baseUrl = args[i + 1];
    }
  }

  print('Running conformance tests against $baseUrl ...\n');

  final client = HttpClient();
  var passed = 0;

  void pass(int num, String desc) {
    passed++;
    print('  [$num/37] OK: $desc');
  }

  void fail(int num, String desc, String reason) {
    print('  [$num/37] FAIL: $desc -> $reason');
    exit(1);
  }

  Future<_Res> req(
    String method,
    String path, {
    Map<String, String>? headers,
    Object? body,
    List<int>? rawBytes,
    String? contentType,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    late HttpClientRequest request;
    if (method == 'GET') {
      request = await client.getUrl(uri);
    } else if (method == 'POST') {
      request = await client.postUrl(uri);
    } else if (method == 'PUT') {
      request = await client.putUrl(uri);
    } else if (method == 'DELETE') {
      request = await client.deleteUrl(uri);
    } else {
      throw UnimplementedError(method);
    }

    headers?.forEach((k, v) => request.headers.set(k, v));

    if (rawBytes != null) {
      if (contentType != null) {
        request.headers.set('content-type', contentType);
      }
      request.headers.contentLength = rawBytes.length;
      request.add(rawBytes);
    } else if (body != null) {
      request.headers.contentType = ContentType.json;
      final jsonStr = jsonEncode(body);
      request.headers.contentLength = utf8.encode(jsonStr).length;
      request.write(jsonStr);
    }

    final response = await request.close();
    final bytes = await response.fold<List<int>>([], (p, e) => p..addAll(e));
    final bodyStr = utf8.decode(bytes, allowMalformed: true);
    Map<String, dynamic>? jsonBody;
    try {
      final decoded = jsonDecode(bodyStr);
      if (decoded is Map<String, dynamic>) jsonBody = decoded;
    } catch (_) {}

    return _Res(
      statusCode: response.statusCode,
      body: bodyStr,
      json: jsonBody,
      headers: response.headers,
    );
  }

  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final emailA = 'user_a_$timestamp@test.com';
  final emailB = 'user_b_$timestamp@test.com';
  String tokenA = '';
  String tokenB = '';
  String noteId1 = '';

  // 1. GET /health
  var r = await req('GET', '/health');
  if (r.statusCode == 200 && r.json?['status'] == 'ok') {
    pass(1, 'GET /health -> 200 ok');
  } else {
    fail(1, 'GET /health', 'Expected 200 {"status":"ok"}, got ${r.statusCode} ${r.body}');
  }

  // 2. Register invalid email
  r = await req('POST', '/auth/register', body: {'email': 'invalid', 'password': 'pass', 'name': 'A'});
  if (r.statusCode == 400 && r.json?['error']?['code'] == 'VALIDATION_ERROR') {
    pass(2, 'POST /auth/register invalid email -> 400 VALIDATION_ERROR');
  } else {
    fail(2, 'Register invalid email', 'Got ${r.statusCode} ${r.body}');
  }

  // 3. Register missing password
  r = await req('POST', '/auth/register', body: {'email': emailA, 'name': 'A'});
  if (r.statusCode == 400 && r.json?['error']?['code'] == 'VALIDATION_ERROR') {
    pass(3, 'POST /auth/register missing password -> 400 VALIDATION_ERROR');
  } else {
    fail(3, 'Register missing password', 'Got ${r.statusCode} ${r.body}');
  }

  // 4. Register missing name
  r = await req('POST', '/auth/register', body: {'email': emailA, 'password': 'pass'});
  if (r.statusCode == 400 && r.json?['error']?['code'] == 'VALIDATION_ERROR') {
    pass(4, 'POST /auth/register missing name -> 400 VALIDATION_ERROR');
  } else {
    fail(4, 'Register missing name', 'Got ${r.statusCode} ${r.body}');
  }

  // 5. Register User A
  r = await req('POST', '/auth/register', body: {'email': emailA, 'password': 'password123', 'name': 'User A'});
  if (r.statusCode == 201 && r.json?['token'] is String) {
    tokenA = r.json!['token'] as String;
    pass(5, 'POST /auth/register User A -> 201 token');
  } else {
    fail(5, 'Register User A', 'Got ${r.statusCode} ${r.body}');
  }

  // 6. Duplicate email User A
  r = await req('POST', '/auth/register', body: {'email': emailA, 'password': 'password123', 'name': 'User A'});
  if (r.statusCode == 409 && r.json?['error']?['code'] == 'EMAIL_TAKEN') {
    pass(6, 'POST /auth/register duplicate email -> 409 EMAIL_TAKEN');
  } else {
    fail(6, 'Register duplicate email', 'Got ${r.statusCode} ${r.body}');
  }

  // 7. Login missing credentials
  r = await req('POST', '/auth/login', body: {'email': emailA});
  if (r.statusCode == 401 && r.json?['error']?['code'] == 'UNAUTHORIZED') {
    pass(7, 'POST /auth/login missing password -> 401 UNAUTHORIZED');
  } else {
    fail(7, 'Login missing credentials', 'Got ${r.statusCode} ${r.body}');
  }

  // 8. Login wrong password
  r = await req('POST', '/auth/login', body: {'email': emailA, 'password': 'wrongpassword'});
  if (r.statusCode == 401 && r.json?['error']?['code'] == 'UNAUTHORIZED') {
    pass(8, 'POST /auth/login wrong password -> 401 UNAUTHORIZED');
  } else {
    fail(8, 'Login wrong password', 'Got ${r.statusCode} ${r.body}');
  }

  // 9. Login User A
  r = await req('POST', '/auth/login', body: {'email': emailA, 'password': 'password123'});
  if (r.statusCode == 200 && r.json?['token'] is String) {
    pass(9, 'POST /auth/login valid credentials -> 200 token');
  } else {
    fail(9, 'Login User A', 'Got ${r.statusCode} ${r.body}');
  }

  // 10. GET /me no token
  r = await req('GET', '/me');
  if (r.statusCode == 401 && r.json?['error']?['code'] == 'UNAUTHORIZED') {
    pass(10, 'GET /me without token -> 401 UNAUTHORIZED');
  } else {
    fail(10, 'GET /me no token', 'Got ${r.statusCode} ${r.body}');
  }

  // 11. GET /me invalid token
  r = await req('GET', '/me', headers: {'Authorization': 'Bearer invalid.token.str'});
  if (r.statusCode == 401 && r.json?['error']?['code'] == 'UNAUTHORIZED') {
    pass(11, 'GET /me invalid token -> 401 UNAUTHORIZED');
  } else {
    fail(11, 'GET /me invalid token', 'Got ${r.statusCode} ${r.body}');
  }

  // 12. GET /me with token A
  r = await req('GET', '/me', headers: {'Authorization': 'Bearer $tokenA'});
  if (r.statusCode == 200 && r.json?['email'] == emailA) {
    pass(12, 'GET /me valid token -> 200 profile');
  } else {
    fail(12, 'GET /me valid token', 'Got ${r.statusCode} ${r.body}');
  }

  // 13. Register User B
  r = await req('POST', '/auth/register', body: {'email': emailB, 'password': 'password123', 'name': 'User B'});
  if (r.statusCode == 201 && r.json?['token'] is String) {
    tokenB = r.json!['token'] as String;
    pass(13, 'POST /auth/register User B -> 201 token');
  } else {
    fail(13, 'Register User B', 'Got ${r.statusCode} ${r.body}');
  }

  // 14. GET /notes empty for User A
  r = await req('GET', '/notes', headers: {'Authorization': 'Bearer $tokenA'});
  if (r.statusCode == 200 && r.json?['items'] is List && (r.json!['items'] as List).isEmpty) {
    pass(14, 'GET /notes empty list -> 200 []');
  } else {
    fail(14, 'GET /notes empty', 'Got ${r.statusCode} ${r.body}');
  }

  // 15. POST /notes missing title
  r = await req('POST', '/notes', headers: {'Authorization': 'Bearer $tokenA'}, body: {'content': 'no title'});
  if (r.statusCode == 400 && r.json?['error']?['code'] == 'VALIDATION_ERROR') {
    pass(15, 'POST /notes missing title -> 400 VALIDATION_ERROR');
  } else {
    fail(15, 'POST /notes missing title', 'Got ${r.statusCode} ${r.body}');
  }

  // 16. POST /notes invalid json
  r = await req('POST', '/notes', headers: {'Authorization': 'Bearer $tokenA'}, rawBytes: utf8.encode('not json'), contentType: 'application/json');
  if (r.statusCode == 400 && r.json?['error']?['code'] == 'VALIDATION_ERROR') {
    pass(16, 'POST /notes invalid json -> 400 VALIDATION_ERROR');
  } else {
    fail(16, 'POST /notes invalid json', 'Got ${r.statusCode} ${r.body}');
  }

  // 17. POST /notes Note 1
  r = await req('POST', '/notes', headers: {'Authorization': 'Bearer $tokenA'}, body: {'title': 'Note 1', 'content': 'Content 1'});
  if (r.statusCode == 201 && r.json?['id'] != null) {
    noteId1 = '${r.json!['id']}';
    pass(17, 'POST /notes Note 1 -> 201 created');
  } else {
    fail(17, 'POST /notes Note 1', 'Got ${r.statusCode} ${r.body}');
  }

  // 18. POST /notes Note 2
  r = await req('POST', '/notes', headers: {'Authorization': 'Bearer $tokenA'}, body: {'title': 'Note 2', 'content': 'Content 2'});
  if (r.statusCode == 201) {
    pass(18, 'POST /notes Note 2 -> 201 created');
  } else {
    fail(18, 'POST /notes Note 2', 'Got ${r.statusCode} ${r.body}');
  }

  // 19. POST /notes Note 3
  r = await req('POST', '/notes', headers: {'Authorization': 'Bearer $tokenA'}, body: {'title': 'Note 3', 'content': 'Content 3'});
  if (r.statusCode == 201) {
    pass(19, 'POST /notes Note 3 -> 201 created');
  } else {
    fail(19, 'POST /notes Note 3', 'Got ${r.statusCode} ${r.body}');
  }

  // 20. GET /notes list User A notes (3 items)
  r = await req('GET', '/notes', headers: {'Authorization': 'Bearer $tokenA'});
  if (r.statusCode == 200 && r.json?['total'] == 3 && (r.json!['items'] as List).length == 3) {
    pass(20, 'GET /notes list User A notes -> 200 (total 3)');
  } else {
    fail(20, 'GET /notes User A', 'Got ${r.statusCode} ${r.body}');
  }

  // 21. GET /notes?limit=2
  r = await req('GET', '/notes?limit=2', headers: {'Authorization': 'Bearer $tokenA'});
  if (r.statusCode == 200 && (r.json!['items'] as List).length == 2 && r.json!['total'] == 3) {
    pass(21, 'GET /notes?limit=2 -> 200 (2 items)');
  } else {
    fail(21, 'GET /notes?limit=2', 'Got ${r.statusCode} ${r.body}');
  }

  // 22. GET /notes?page=2&limit=2
  r = await req('GET', '/notes?page=2&limit=2', headers: {'Authorization': 'Bearer $tokenA'});
  if (r.statusCode == 200 && (r.json!['items'] as List).length == 1 && r.json!['page'] == 2) {
    pass(22, 'GET /notes?page=2&limit=2 -> 200 (1 item)');
  } else {
    fail(22, 'GET /notes?page=2&limit=2', 'Got ${r.statusCode} ${r.body}');
  }

  // 23. GET /notes?search=Note%201
  r = await req('GET', '/notes?search=Note%201', headers: {'Authorization': 'Bearer $tokenA'});
  if (r.statusCode == 200 && r.json?['total'] == 1 && (r.json!['items'] as List).length == 1) {
    pass(23, 'GET /notes?search=Note%201 -> 200 (1 item)');
  } else {
    fail(23, 'GET /notes?search=Note%201', 'Got ${r.statusCode} ${r.body}');
  }

  // 24. GET /notes/<id1>
  r = await req('GET', '/notes/$noteId1', headers: {'Authorization': 'Bearer $tokenA'});
  if (r.statusCode == 200 && '${r.json?['id']}' == noteId1) {
    pass(24, 'GET /notes/<id1> -> 200 note');
  } else {
    fail(24, 'GET /notes/<id1>', 'Got ${r.statusCode} ${r.body}');
  }

  // 25. GET /notes/99999
  r = await req('GET', '/notes/99999', headers: {'Authorization': 'Bearer $tokenA'});
  if (r.statusCode == 404 && r.json?['error']?['code'] == 'NOT_FOUND') {
    pass(25, 'GET /notes/99999 -> 404 NOT_FOUND');
  } else {
    fail(25, 'GET /notes/99999', 'Got ${r.statusCode} ${r.body}');
  }

  // 26. GET /notes/<id1> with User B token
  r = await req('GET', '/notes/$noteId1', headers: {'Authorization': 'Bearer $tokenB'});
  if (r.statusCode == 404 && r.json?['error']?['code'] == 'NOT_FOUND') {
    pass(26, 'GET /notes/<id1> with User B token -> 404 NOT_FOUND');
  } else {
    fail(26, 'GET /notes/<id1> User B', 'Got ${r.statusCode} ${r.body}');
  }

  // 27. PUT /notes/<id1> update
  r = await req('PUT', '/notes/$noteId1', headers: {'Authorization': 'Bearer $tokenA'}, body: {'title': 'Updated Title', 'content': 'Updated Content'});
  if (r.statusCode == 200 && r.json?['title'] == 'Updated Title') {
    pass(27, 'PUT /notes/<id1> -> 200 updated');
  } else {
    fail(27, 'PUT /notes/<id1>', 'Got ${r.statusCode} ${r.body}');
  }

  // 28. PUT /notes/<id1> with User B token
  r = await req('PUT', '/notes/$noteId1', headers: {'Authorization': 'Bearer $tokenB'}, body: {'title': 'Hacked', 'content': 'Hacked'});
  if (r.statusCode == 404 && r.json?['error']?['code'] == 'NOT_FOUND') {
    pass(28, 'PUT /notes/<id1> with User B token -> 404 NOT_FOUND');
  } else {
    fail(28, 'PUT /notes/<id1> User B', 'Got ${r.statusCode} ${r.body}');
  }

  // 29. PUT /notes/<id1> missing title
  r = await req('PUT', '/notes/$noteId1', headers: {'Authorization': 'Bearer $tokenA'}, body: {'content': 'No title'});
  if (r.statusCode == 400 && r.json?['error']?['code'] == 'VALIDATION_ERROR') {
    pass(29, 'PUT /notes/<id1> missing title -> 400 VALIDATION_ERROR');
  } else {
    fail(29, 'PUT /notes/<id1> missing title', 'Got ${r.statusCode} ${r.body}');
  }

  // 30. DELETE /notes/<id1> with User B token
  r = await req('DELETE', '/notes/$noteId1', headers: {'Authorization': 'Bearer $tokenB'});
  if (r.statusCode == 404 && r.json?['error']?['code'] == 'NOT_FOUND') {
    pass(30, 'DELETE /notes/<id1> with User B token -> 404 NOT_FOUND');
  } else {
    fail(30, 'DELETE /notes/<id1> User B', 'Got ${r.statusCode} ${r.body}');
  }

  // 31. DELETE /notes/<id1>
  r = await req('DELETE', '/notes/$noteId1', headers: {'Authorization': 'Bearer $tokenA'});
  if (r.statusCode == 204) {
    pass(31, 'DELETE /notes/<id1> -> 204 No Content');
  } else {
    fail(31, 'DELETE /notes/<id1>', 'Got ${r.statusCode} ${r.body}');
  }

  // 32. GET /notes/<id1> after delete
  r = await req('GET', '/notes/$noteId1', headers: {'Authorization': 'Bearer $tokenA'});
  if (r.statusCode == 404 && r.json?['error']?['code'] == 'NOT_FOUND') {
    pass(32, 'GET /notes/<id1> after delete -> 404 NOT_FOUND');
  } else {
    fail(32, 'GET /notes/<id1> after delete', 'Got ${r.statusCode} ${r.body}');
  }

  // 33. POST /files invalid body (not multipart)
  r = await req('POST', '/files', headers: {'Authorization': 'Bearer $tokenA'}, body: {'test': '123'});
  if (r.statusCode == 400 && r.json?['error']?['code'] == 'VALIDATION_ERROR') {
    pass(33, 'POST /files invalid body -> 400 VALIDATION_ERROR');
  } else {
    fail(33, 'POST /files invalid body', 'Got ${r.statusCode} ${r.body}');
  }

  // 34. POST /files upload file
  const boundary = '----WebKitFormBoundaryTest7MA4YWxkTrZu0gW';
  final fileContent = utf8.encode('Hello World File Content');
  final mpBody = BytesBuilder()
    ..add(utf8.encode('--$boundary\r\n'))
    ..add(utf8.encode('Content-Disposition: form-data; name="file"; filename="test.txt"\r\n'))
    ..add(utf8.encode('Content-Type: text/plain\r\n\r\n'))
    ..add(fileContent)
    ..add(utf8.encode('\r\n--$boundary--\r\n'));

  r = await req(
    'POST',
    '/files',
    headers: {'Authorization': 'Bearer $tokenA'},
    rawBytes: mpBody.toBytes(),
    contentType: 'multipart/form-data; boundary=$boundary',
  );

  String fileUrl = '';
  if (r.statusCode == 201 && r.json?['url'] is String) {
    fileUrl = r.json!['url'] as String;
    pass(34, 'POST /files valid file -> 201 url');
  } else {
    fail(34, 'POST /files valid file', 'Got ${r.statusCode} ${r.body}');
  }

  // 35. GET /files/<id> download file
  r = await req('GET', fileUrl);
  if (r.statusCode == 200 && r.body == 'Hello World File Content') {
    pass(35, 'GET /files/<id> -> 200 bytes match');
  } else {
    fail(35, 'GET /files/<id>', 'Got ${r.statusCode} ${r.body}');
  }

  // 36. GET /files/<id> headers
  final disp = r.headers.value('content-disposition');
  final csp = r.headers.value('content-security-policy');
  if (disp == 'attachment' && csp == "default-src 'none'; sandbox") {
    pass(36, 'GET /files/<id> security headers OK');
  } else {
    fail(36, 'GET /files/<id> headers', 'Got disp=$disp, csp=$csp');
  }

  // 37. GET /files/99999
  r = await req('GET', '/files/99999');
  if (r.statusCode == 404 && r.json?['error']?['code'] == 'NOT_FOUND') {
    pass(37, 'GET /files/99999 -> 404 NOT_FOUND');
  } else {
    fail(37, 'GET /files/99999', 'Got ${r.statusCode} ${r.body}');
  }

  print('\nPASS $passed/37 checks passed');
  client.close();
}

class _Res {
  final int statusCode;
  final String body;
  final Map<String, dynamic>? json;
  final HttpHeaders headers;

  _Res({
    required this.statusCode,
    required this.body,
    required this.json,
    required this.headers,
  });
}
