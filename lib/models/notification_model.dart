class NotificationModel {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // طباعة للتأكد من شكل البيانات الجديد
    print("Debug - Received JSON: $json");

    return NotificationModel(
      id: json['id'] ?? 0,
      // القراءة مباشرة من json وليس من dataField
      title: json['title'] ?? 'تنبيه جديد',
      body: json['body'] ?? json['message'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      // تأكد من اسم الحقل في جدولك (هل هو is_read أم read_at؟)
      isRead: json['read_at'] != null || json['is_read'] == 1,
    );
  }
}
