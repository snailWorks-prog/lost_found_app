import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';

import 'auth.dart';
import 'db.dart';
import 'errors.dart';

Map<String, dynamic> _claimToJson(Row row) => {
      'id': '${row['id']}',
      'itemId': row['item_id'],
      'itemTitle': row['item_title'],
      'proofDescription': row['proof_description'],
      'date': row['created_at'],
      'status': row['status'],
    };

Map<String, dynamic> _messageToJson(Row row, int currentUserId) => {
      'id': '${row['id']}',
      'claimId': row['claim_id'],
      'text': row['text'],
      'time': row['time'],
      'isMe': (row['user_id'] as int) == currentUserId,
      'createdAt': row['created_at'],
    };

Row? _findClaim(int userId, String? idParam) {
  final id = int.tryParse(idParam ?? '');
  if (id == null) return null;
  final rows = db.select(
    'SELECT * FROM claims WHERE id = ? AND user_id = ?',
    [id, userId],
  );
  return rows.isEmpty ? null : rows.first;
}

Future<Response> listClaims(Request request) async {
  final userId = currentUserId(request);
  final query = request.url.queryParameters;
  final page = max(int.tryParse(query['page'] ?? '') ?? 1, 1);
  final limit = (int.tryParse(query['limit'] ?? '') ?? 50).clamp(1, 100);

  final total =
      db.select('SELECT COUNT(*) AS n FROM claims WHERE user_id = ?', [userId])
          .first['n'] as int;
  final rows = db.select(
    'SELECT * FROM claims WHERE user_id = ? ORDER BY id DESC LIMIT ? OFFSET ?',
    [userId, limit, (page - 1) * limit],
  );

  return jsonResponse({
    'items': rows.map(_claimToJson).toList(),
    'page': page,
    'limit': limit,
    'total': total,
  });
}

Future<Response> createClaim(Request request) async {
  final userId = currentUserId(request);
  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');

  final itemTitle = stringField(body, 'itemTitle') ?? 'Вещь';
  final proofDescription = stringField(body, 'proofDescription');
  if (proofDescription == null) {
    return validationError('proofDescription is required');
  }

  final itemId = body['itemId'] is String ? body['itemId'] as String : '0';
  final status =
      body['status'] is String ? body['status'] as String : 'pending';

  db.execute(
    'INSERT INTO claims (user_id, item_id, item_title, proof_description, status, created_at) '
    'VALUES (?, ?, ?, ?, ?, ?)',
    [userId, itemId, itemTitle, proofDescription, status, nowIso()],
  );

  final row = _findClaim(userId, '${db.lastInsertRowId}')!;
  return jsonResponse(_claimToJson(row), status: 201);
}

Future<Response> deleteClaim(Request request) async {
  final userId = currentUserId(request);
  final row = _findClaim(userId, request.params['id']);
  if (row == null) return notFound('Claim not found');
  db.execute('DELETE FROM claims WHERE id = ?', [row['id']]);
  return Response(204);
}

Future<Response> listMessages(Request request) async {
  final userId = currentUserId(request);
  final claimId = request.params['id'] ?? '';

  final rows = db.select(
    'SELECT * FROM messages WHERE claim_id = ? ORDER BY id ASC',
    [claimId],
  );

  return jsonResponse({
    'items': rows.map((r) => _messageToJson(r, userId)).toList(),
  });
}

Future<Response> createMessage(Request request) async {
  final userId = currentUserId(request);
  final claimId = request.params['id'] ?? '';
  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');

  final text = stringField(body, 'text');
  if (text == null) return validationError('text is required');

  final now = DateTime.now();
  final timeStr =
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

  db.execute(
    'INSERT INTO messages (claim_id, user_id, text, time, is_me, created_at) '
    'VALUES (?, ?, ?, ?, ?, ?)',
    [claimId, userId, text, timeStr, 1, nowIso()],
  );

  final msgId = db.lastInsertRowId;
  final row = db.select('SELECT * FROM messages WHERE id = ?', [msgId]).first;
  return jsonResponse(_messageToJson(row, userId), status: 201);
}
