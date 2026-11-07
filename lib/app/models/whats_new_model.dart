class WhatsNewModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? productUrl;
  final String language;
  final int order;
  final bool isActive;
  final DateTime? createdAt;

  WhatsNewModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.productUrl,
    required this.language,
    required this.order,
    required this.isActive,
    this.createdAt,
  });

  factory WhatsNewModel.fromJson(Map<String, dynamic> json) {
    return WhatsNewModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      productUrl: json['productUrl'],
      language: json['language'] ?? 'en',
      order: json['order'] ?? 0,
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
