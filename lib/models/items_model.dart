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

  int _page = 1;
  final int _limit = 20;
  bool _hasMore = false;
  bool _loadingMore = false;
  String _search = '';

  bool get isLoading => _loading;
  String? get error => _error;
  List<CampusItem> get items => List.unmodifiable(_items);

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _loadingMore;
  String get search => _search;

  int get activeCount => _items.where((i) => !i.isResolved).length;
  int get resolvedCount => _items.where((i) => i.isResolved).length;

  CampusItem? byId(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> load({String? search}) async {
    _search = search ?? _search;
    _page = 1;
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.fetchItems(
      page: 1,
      limit: _limit,
      search: _search,
    );
    switch (result) {
      case Ok(:final value):
        _items = List.from(value);
        _hasMore = value.length == _limit;
        _error = null;
      case Err(:final msg):
        _error = msg;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loadingMore || _loading || !_hasMore) return;

    _loadingMore = true;

    final nextPage = _page + 1;
    final result = await _repository.fetchItems(
      page: nextPage,
      limit: _limit,
      search: _search,
    );

    switch (result) {
      case Ok(:final value):
        _page = nextPage;
        _items = [..._items, ...value];
        _hasMore = value.length == _limit;
      case Err():
        _hasMore = false;
    }

    _loadingMore = false;
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
