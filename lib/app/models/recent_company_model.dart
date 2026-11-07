class RecentCompanyModel {
  final String id;
  final String companyName;
  final String companyLogo;
  final String country;
  final DateTime? createdAt;

  RecentCompanyModel({
    required this.id,
    required this.companyName,
    required this.companyLogo,
    required this.country,
    this.createdAt,
  });

  factory RecentCompanyModel.fromJson(Map<String, dynamic> json) {
    return RecentCompanyModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      companyName: json['companyName'] ?? '',
      companyLogo: json['companyLogo'] ?? '',
      country: json['country'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
