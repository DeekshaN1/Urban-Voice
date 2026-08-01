class ReportModel {
  final String id;
  final String userEmail;
  final String userName;
  final String userId;
  final String category;
  final String description;
  final String priority;
  final double? latitude;
  final double? longitude;
  String status;
  final DateTime createdAt;
  final String? imageUrl;

  ReportModel({
    required this.id,
    required this.userEmail,
    required this.userName,
    required this.userId,
    required this.category,
    required this.description,
    required this.priority,
    this.latitude,
    this.longitude,
    this.status = 'Under Process',
    required this.createdAt,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userEmail': userEmail,
        'userName': userName,
        'userId': userId,
        'category': category,
        'description': description,
        'priority': priority,
        'latitude': latitude,
        'longitude': longitude,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'imageUrl': imageUrl,
      };

  factory ReportModel.fromMap(Map<String, dynamic> map) => ReportModel(
        id: map['id'] ?? '',
        userEmail: map['userEmail'] ?? '',
        userName: map['userName'] ?? '',
        userId: map['userId'] ?? '',
        category: map['category'] ?? '',
        description: map['description'] ?? '',
        priority: map['priority'] ?? 'Medium',
        latitude: map['latitude']?.toDouble(),
        longitude: map['longitude']?.toDouble(),
        status: map['status'] ?? 'Under Process',
        createdAt: DateTime.parse(
          map['createdAt'] ?? DateTime.now().toIso8601String(),
        ),
        imageUrl: map['imageUrl'],
      );
}
