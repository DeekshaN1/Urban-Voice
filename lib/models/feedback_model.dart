class FeedbackModel {
  final String id;
  final String service;
  final int rating;
  final String text;
  final String userName;
  final String userEmail;
  final DateTime createdAt;

  FeedbackModel({
    required this.id,
    required this.service,
    required this.rating,
    required this.text,
    required this.userName,
    required this.userEmail,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'service': service,
        'rating': rating,
        'text': text,
        'userName': userName,
        'userEmail': userEmail,
        'createdAt': createdAt.toIso8601String(),
      };

  factory FeedbackModel.fromMap(Map<String, dynamic> map) => FeedbackModel(
        id: map['id'] ?? '',
        service: map['service'] ?? '',
        rating: map['rating'] ?? 0,
        text: map['text'] ?? '',
        userName: map['userName'] ?? '',
        userEmail: map['userEmail'] ?? '',
        createdAt: DateTime.parse(
          map['createdAt'] ?? DateTime.now().toIso8601String(),
        ),
      );
}
