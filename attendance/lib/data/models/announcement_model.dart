/// Announcement Model
class AnnouncementModel {
  final String id;
  final String managerId;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isPinned;

  const AnnouncementModel({
    required this.id,
    required this.managerId,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isPinned = false,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String,
      managerId: json['managerId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'managerId': managerId,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isPinned': isPinned,
    };
  }
}
