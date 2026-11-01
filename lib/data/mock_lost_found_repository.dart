import 'lost_found_repository.dart';
import 'mock_data.dart';
import 'models.dart';
import 'result.dart';

class MockLostFoundRepository implements LostFoundRepository {
  final List<CampusItem> _items = List.from(mockItems);
  final List<CampusClaim> _claims = List.from(mockClaims);
  final Map<String, List<ChatMessage>> _messages = {
    'c1': List.from(mockMessages),
  };

  int _nextId = 100;
  bool simulateError = false;

  static const _latency = Duration(milliseconds: 800);
  static const _errNetwork = 'Сервер кампуса не отвечает — повторите попытку';

  @override
  Future<Result<List<CampusItem>>> fetchItems() async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    return Ok(List.unmodifiable(_items));
  }

  @override
  Future<Result<CampusItem>> fetchItemById(String id) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    try {
      final item = _items.firstWhere((element) => element.id == id);
      return Ok(item);
    } catch (_) {
      return const Err('Объявление не найдено');
    }
  }

  @override
  Future<Result<CampusItem>> createItem(CampusItem draft) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final newItem = draft.copyWith(id: '${_nextId++}');
    _items.insert(0, newItem);
    return Ok(newItem);
  }

  @override
  Future<Result<CampusItem>> updateItem(CampusItem item) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final index = _items.indexWhere((element) => element.id == item.id);
    if (index == -1) {
      return const Err('Запись не существует');
    }
    _items[index] = item;
    return Ok(item);
  }

  @override
  Future<Result<void>> deleteItem(String id) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final index = _items.indexWhere((element) => element.id == id);
    if (index == -1) {
      return const Err('Запись не существует');
    }
    _items.removeAt(index);
    return const Ok(null);
  }

  @override
  Future<Result<List<CampusClaim>>> fetchClaims() async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    return Ok(List.unmodifiable(_claims));
  }

  @override
  Future<Result<CampusClaim>> createClaim(CampusClaim draft) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final newClaim = draft.copyWith(id: 'c${_nextId++}');
    _claims.insert(0, newClaim);
    _messages[newClaim.id] = [];
    return Ok(newClaim);
  }

  @override
  Future<Result<void>> deleteClaim(String id) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final index = _claims.indexWhere((element) => element.id == id);
    if (index == -1) {
      return const Err('Запись не существует');
    }
    _claims.removeAt(index);
    return const Ok(null);
  }

  @override
  Future<Result<List<ChatMessage>>> fetchMessages(String claimId) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final messages = _messages[claimId] ?? [];
    return Ok(List.unmodifiable(messages));
  }

  @override
  Future<Result<ChatMessage>> sendMessage(String claimId, String text) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final msg = ChatMessage(text: text, time: timeStr, isMe: true);
    final list = _messages[claimId] ?? [];
    list.add(msg);
    _messages[claimId] = list;
    return Ok(msg);
  }
}
