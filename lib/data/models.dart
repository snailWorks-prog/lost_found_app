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
  final String? imageUrl;

  const CampusItem({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.type,
    required this.category,
    this.isResolved = false,
    this.imageUrl,
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
    String? imageUrl,
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
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory CampusItem.fromJson(Map<String, dynamic> j) {
    return CampusItem(
      id: '${j['id']}',
      title: (j['title'] as String?) ?? '',
      description: (j['description'] as String?) ?? '',
      location: (j['location'] as String?) ?? '',
      date: (j['date'] as String?) ?? '',
      type: j['type'] == 'lost' ? ItemType.lost : ItemType.found,
      category: (j['category'] as String?) ?? 'Разное',
      isResolved: j['isResolved'] == true,
      imageUrl: j['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != '0') 'id': id,
      'title': title,
      'description': description,
      'location': location,
      'date': date,
      'type': type == ItemType.lost ? 'lost' : 'found',
      'category': category,
      'isResolved': isResolved,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
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

  factory ChatMessage.fromJson(Map<String, dynamic> j) {
    return ChatMessage(
      text: (j['text'] as String?) ?? '',
      time: (j['time'] as String?) ?? '',
      isMe: j['isMe'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'time': time,
      'isMe': isMe,
    };
  }
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

  factory CampusClaim.fromJson(Map<String, dynamic> j) {
    ClaimStatus st = ClaimStatus.pending;
    if (j['status'] == 'accepted') st = ClaimStatus.accepted;
    if (j['status'] == 'rejected') st = ClaimStatus.rejected;

    return CampusClaim(
      id: '${j['id']}',
      itemTitle: (j['itemTitle'] as String?) ?? '',
      proofDescription: (j['proofDescription'] as String?) ?? '',
      date: (j['date'] as String?) ?? '',
      status: st,
    );
  }

  Map<String, dynamic> toJson() {
    String stStr = 'pending';
    if (status == ClaimStatus.accepted) stStr = 'accepted';
    if (status == ClaimStatus.rejected) stStr = 'rejected';

    return {
      if (id != '0') 'id': id,
      'itemTitle': itemTitle,
      'proofDescription': proofDescription,
      'date': date,
      'status': stStr,
    };
  }
}
