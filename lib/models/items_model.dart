import 'package:flutter/foundation.dart';
import '../data/lost_found_repository.dart';
import '../data/models.dart';
import '../data/result.dart';

class ItemsModel extends ChangeNotifier {
  final LostFoundRepository _repository;

  ItemsModel(this._repository);

  bool _loading = false;
  String? _error;
  List<CampusItem> _items = const [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<CampusItem> get items => List.unmodifiable(_items);

  int get activeCount => _items.where((i) => !i.isResolved).length;
  int get resolvedCount => _items.where((i) => i.isResolved).length;

  CampusItem? byId(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.fetchItems();
    switch (result) {
      case Ok(:final value):
        _items = List.from(value);
        _error = null;
      case Err(:final msg):
        _error = msg;
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> addItem(CampusItem draft) async {
    final result = await _repository.createItem(draft);
    switch (result) {
      case Ok(:final value):
        _items = [value, ..._items];
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  Future<String?> toggleResolved(String id) async {
    final item = byId(id);
    if (item == null) return 'Объявление не найдено';

    final updated = item.copyWith(isResolved: !item.isResolved);
    final result = await _repository.updateItem(updated);
    switch (result) {
      case Ok(:final value):
        final index = _items.indexWhere((i) => i.id == id);
        if (index != -1) {
          final newList = List<CampusItem>.from(_items);
          newList[index] = value;
          _items = newList;
          notifyListeners();
        }
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  Future<String?> removeItem(String id) async {
    final result = await _repository.deleteItem(id);
    switch (result) {
      case Ok():
        _items = _items.where((i) => i.id != id).toList();
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }
}
