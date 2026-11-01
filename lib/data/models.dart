enum ItemType { lost, found }
enum ClaimStatus { pending, accepted, rejected }

class CampusItem {
  final String id;
  final String title;
  final String description;
  final String location;
  final String date;
  final ItemType type;
  final String category;
  final bool isResolved;

  const CampusItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.type,
    required this.category,
    this.isResolved = false,
  });

  CampusItem copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? date,
    ItemType? type,
    String? category,
    bool? isResolved,
  }) {
    return CampusItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}

class ChatMessage {
  final String text;
  final String time;
  final bool isMe;

  const ChatMessage({
    required this.text,
    required this.time,
    required this.isMe,
  });
}

class CampusClaim {
  final String id;
  final String itemTitle;
  final String proofDescription;
  final String date;
  final ClaimStatus status;

  const CampusClaim({
    required this.id,
    required this.itemTitle,
    required this.proofDescription,
    required this.date,
    required this.status,
  });

  CampusClaim copyWith({
    String? id,
    String? itemTitle,
    String? proofDescription,
    String? date,
    ClaimStatus? status,
  }) {
    return CampusClaim(
      id: id ?? this.id,
      itemTitle: itemTitle ?? this.itemTitle,
      proofDescription: proofDescription ?? this.proofDescription,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}
