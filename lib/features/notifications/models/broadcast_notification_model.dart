class BroadcastNotificationModel {
  final String id;
  final String title;
  final String body;
  final String sentAt;
  final String? imageUrl;
  final String type;
  final bool isActive;

  const BroadcastNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.sentAt,
    this.imageUrl,
    this.type = 'broadcast',
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'sentAt': sentAt,
        'imageUrl': imageUrl,
        'type': type,
        'isActive': isActive,
      };

  factory BroadcastNotificationModel.fromJson(Map<String, dynamic> json) {
    return BroadcastNotificationModel(
      id: json['id']?.toString() ?? 'notif-${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? '',
      sentAt: json['sentAt']?.toString() ?? DateTime.now().toIso8601String(),
      imageUrl: json['imageUrl']?.toString(),
      type: json['type']?.toString() ?? 'broadcast',
      isActive: json['isActive'] ?? true,
    );
  }
}
