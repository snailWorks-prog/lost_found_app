import 'models.dart';
import 'result.dart';

abstract class LostFoundRepository {
  Future<Result<List<CampusItem>>> fetchItems();
  Future<Result<CampusItem>> fetchItemById(String id);
  Future<Result<CampusItem>> createItem(CampusItem draft);
  Future<Result<CampusItem>> updateItem(CampusItem item);
  Future<Result<void>> deleteItem(String id);

  Future<Result<List<CampusClaim>>> fetchClaims();
  Future<Result<CampusClaim>> createClaim(CampusClaim draft);
  Future<Result<void>> deleteClaim(String id);

  Future<Result<List<ChatMessage>>> fetchMessages(String claimId);
  Future<Result<ChatMessage>> sendMessage(String claimId, String text);
}
