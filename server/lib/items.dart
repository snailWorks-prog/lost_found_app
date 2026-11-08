import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:sqlite3/sqlite3.dart';

import 'auth.dart';
import 'db.dart';
import 'errors.dart';

Map<String, dynamic> _toJson(Row row) => {
      'id': '${row['id']}',
      'title': row['title'],
      'description': row['description'],
      'location': row['location'],
      'date': row['date'],
      'type': row['type'],
      'category': row['category'],
      'isResolved': (row['is_resolved'] as int) == 1,
      'imageUrl': row['image_url'],
      'createdAt': row['created_at'],
    };

Row? _findItem(int userId, String? idParam) {
  final id = int.tryParse(idParam ?? '');
  if (id == null) return null;
  final rows = db.select(
    'SELECT * FROM items WHERE id = ? AND user_id = ?',
    [id, userId],
  );
  return rows.isEmpty ? null : rows.first;
}

Future<Response> listItems(Request request) async {
  final userId = currentUserId(request);
  seedUserItemsIfEmpty(userId);

  final query = request.url.queryParameters;
  final page = max(int.tryParse(query['page'] ?? '') ?? 1, 1);
  final limit = (int.tryParse(query['limit'] ?? '') ?? 20).clamp(1, 100);
  final search = query['search'] ?? '';

  const where =
      'user_id = ? AND (title LIKE ? OR description LIKE ? OR location LIKE ?)';
  final args = [userId, '%$search%', '%$search%', '%$search%'];

  final total =
      db.select('SELECT COUNT(*) AS n FROM items WHERE $where', args).first['n']
          as int;
  final rows = db.select(
    'SELECT * FROM items WHERE $where ORDER BY id DESC LIMIT ? OFFSET ?',
    [...args, limit, (page - 1) * limit],
  );

  return jsonResponse({
    'items': rows.map(_toJson).toList(),
    'page': page,
    'limit': limit,
    'total': total,
  });
}

Future<Response> createItem(Request request) async {
  final userId = currentUserId(request);
  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');

  final title = stringField(body, 'title');
  if (title == null) return validationError('title is required');

  final description =
      body['description'] is String ? body['description'] as String : '';
  final location =
      body['location'] is String ? body['location'] as String : '';
  final date = body['date'] is String ? body['date'] as String : 'Только что';
  final type = body['type'] is String ? body['type'] as String : 'found';
  final category =
      body['category'] is String ? body['category'] as String : 'Разное';
  final isResolved = body['isResolved'] == true ? 1 : 0;
  final imageUrl =
      body['imageUrl'] is String ? body['imageUrl'] as String : null;

  db.execute(
    'INSERT INTO items (user_id, title, description, location, date, type, category, is_resolved, image_url, created_at) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      userId,
      title,
      description,
      location,
      date,
      type,
      category,
      isResolved,
      imageUrl,
      nowIso()
    ],
  );

  final row = _findItem(userId, '${db.lastInsertRowId}')!;
  return jsonResponse(_toJson(row), status: 201);
}

Future<Response> getItem(Request request) async {
  final userId = currentUserId(request);
  final row = _findItem(userId, request.params['id']);
  if (row == null) return notFound('Item not found');
  return jsonResponse(_toJson(row));
}

Future<Response> updateItem(Request request) async {
  final userId = currentUserId(request);
  final idParam = request.params['id'];
  final row = _findItem(userId, idParam);
  if (row == null) return notFound('Item not found');

  final body = await readJsonBody(request);
  if (body == null) return validationError('Body must be a JSON object');

  final title = stringField(body, 'title') ?? (row['title'] as String);
  final description = body['description'] is String
      ? body['description'] as String
      : (row['description'] as String);
  final location = body['location'] is String
      ? body['location'] as String
      : (row['location'] as String);
  final date = body['date'] is String
      ? body['date'] as String
      : (row['date'] as String);
  final type = body['type'] is String
      ? body['type'] as String
      : (row['type'] as String);
  final category = body['category'] is String
      ? body['category'] as String
      : (row['category'] as String);
  final isResolved = body.containsKey('isResolved')
      ? (body['isResolved'] == true ? 1 : 0)
      : (row['is_resolved'] as int);
  final imageUrl = body.containsKey('imageUrl')
      ? (body['imageUrl'] as String?)
      : (row['image_url'] as String?);

  db.execute(
    'UPDATE items SET title = ?, description = ?, location = ?, date = ?, type = ?, category = ?, is_resolved = ?, image_url = ? WHERE id = ?',
    [
      title,
      description,
      location,
      date,
      type,
      category,
      isResolved,
      imageUrl,
      row['id']
    ],
  );

  final updated = _findItem(userId, idParam)!;
  return jsonResponse(_toJson(updated));
}

Future<Response> deleteItem(Request request) async {
  final userId = currentUserId(request);
  final row = _findItem(userId, request.params['id']);
  if (row == null) return notFound('Item not found');
  db.execute('DELETE FROM items WHERE id = ?', [row['id']]);
  return Response(204);
}
