class BannerModel {
  final String id;
  final String badge;
  final String title;
  final String description;
  final String imageUrl;
  final String publicId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String type;
  final String language;
  final String? productUrl;
  final bool isActive;
  final String createdBy;
  final String createdByModel;
  final int points;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BannerModel({
    required this.id,
    required this.badge,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.publicId,
    this.startDate,
    this.endDate,
    required this.type,
    required this.language,
    this.productUrl,
    required this.isActive,
    required this.createdBy,
    required this.createdByModel,
    required this.points,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      badge: json['badge'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      publicId: json['public_id'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'])
          : null,
      endDate:
          json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      type: json['type'] ?? '',
      language: json['language'] ?? '',
      productUrl: json['productUrl'],
      isActive: json['isActive'] ?? false,
      createdBy: json['createdBy'] ?? '',
      createdByModel: json['createdByModel'] ?? '',
      points: json['points'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'badge': badge,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'public_id': publicId,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'type': type,
      'language': language,
      'productUrl': productUrl,
      'isActive': isActive,
      'createdBy': createdBy,
      'createdByModel': createdByModel,
      'points': points,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
