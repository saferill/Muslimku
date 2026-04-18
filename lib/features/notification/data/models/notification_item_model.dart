class NotificationItemModel {
  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAtEpochMs,
    required this.read,
    this.payload,
    this.routeName,
    this.routeIntArgument,
    this.routeStringArgument,
    this.scheduledAtEpochMs,
  });

  final String id;
  final String title;
  final String body;
  final String category;
  final int createdAtEpochMs;
  final bool read;
  final String? payload;
  final String? routeName;
  final int? routeIntArgument;
  final String? routeStringArgument;
  final int? scheduledAtEpochMs;

  DateTime get createdAt =>
      DateTime.fromMillisecondsSinceEpoch(createdAtEpochMs);
  DateTime? get scheduledAt => scheduledAtEpochMs == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(scheduledAtEpochMs!);

  NotificationItemModel copyWith({
    String? id,
    String? title,
    String? body,
    String? category,
    int? createdAtEpochMs,
    bool? read,
    String? payload,
    String? routeName,
    int? routeIntArgument,
    String? routeStringArgument,
    int? scheduledAtEpochMs,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      createdAtEpochMs: createdAtEpochMs ?? this.createdAtEpochMs,
      read: read ?? this.read,
      payload: payload ?? this.payload,
      routeName: routeName ?? this.routeName,
      routeIntArgument: routeIntArgument ?? this.routeIntArgument,
      routeStringArgument: routeStringArgument ?? this.routeStringArgument,
      scheduledAtEpochMs: scheduledAtEpochMs ?? this.scheduledAtEpochMs,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'category': category,
      'createdAtEpochMs': createdAtEpochMs,
      'read': read,
      'payload': payload,
      'routeName': routeName,
      'routeIntArgument': routeIntArgument,
      'routeStringArgument': routeStringArgument,
      'scheduledAtEpochMs': scheduledAtEpochMs,
    };
  }

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: (json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      body: (json['body'] ?? '') as String,
      category: (json['category'] ?? 'general') as String,
      createdAtEpochMs: (json['createdAtEpochMs'] ?? 0) as int,
      read: (json['read'] ?? false) as bool,
      payload: json['payload'] as String?,
      routeName: json['routeName'] as String?,
      routeIntArgument: json['routeIntArgument'] as int?,
      routeStringArgument: json['routeStringArgument'] as String?,
      scheduledAtEpochMs: json['scheduledAtEpochMs'] as int?,
    );
  }
}
