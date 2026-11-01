import 'package:flutter/foundation.dart';
import '../data/lost_found_repository.dart';
import '../data/models.dart';
import '../data/result.dart';

class ClaimsModel extends ChangeNotifier {
  final LostFoundRepository _repository;

  ClaimsModel(this._repository);

  bool _loading = false;
  String? _error;
  List<CampusClaim> _claims = const [];

  Map<String, List<ChatMessage>> _claimMessages = {};
  bool _loadingMessages = false;
  String? _messagesError;

  bool get isLoading => _loading;
  String? get error => _error;
  List<CampusClaim> get claims => List.unmodifiable(_claims);
  int get count => _claims.length;

  bool get isLoadingMessages => _loadingMessages;
  String? get messagesError => _messagesError;

  List<ChatMessage> getMessages(String claimId) {
    final list = _claimMessages[claimId] ?? const [];
    return List.unmodifiable(list);
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.fetchClaims();
    switch (result) {
      case Ok(:final value):
        _claims = List.from(value);
        _error = null;
      case Err(:final msg):
        _error = msg;
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> addClaim(CampusClaim draft) async {
    final result = await _repository.createClaim(draft);
    switch (result) {
      case Ok(:final value):
        _claims = [value, ..._claims];
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  Future<String?> removeClaim(String id) async {
    final result = await _repository.deleteClaim(id);
    switch (result) {
      case Ok():
        _claims = _claims.where((c) => c.id != id).toList();
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  Future<void> loadMessages(String claimId) async {
    _loadingMessages = true;
    _messagesError = null;
    notifyListeners();

    final result = await _repository.fetchMessages(claimId);
    switch (result) {
      case Ok(:final value):
        final newMap = Map<String, List<ChatMessage>>.from(_claimMessages);
        newMap[claimId] = List.from(value);
        _claimMessages = newMap;
        _messagesError = null;
      case Err(:final msg):
        _messagesError = msg;
    }
    _loadingMessages = false;
    notifyListeners();
  }

  Future<String?> sendMessage(String claimId, String text) async {
    final result = await _repository.sendMessage(claimId, text);
    switch (result) {
      case Ok(:final value):
        final current = List<ChatMessage>.from(_claimMessages[claimId] ?? []);
        current.add(value);
        final newMap = Map<String, List<ChatMessage>>.from(_claimMessages);
        newMap[claimId] = current;
        _claimMessages = newMap;
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }
}
