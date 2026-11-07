class TopClaimProductModel {
  final String id;
  final String name;
  final String image;
  final int redeemPoints;
  final String companyName;

  TopClaimProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.redeemPoints,
    required this.companyName,
  });

  factory TopClaimProductModel.fromJson(Map<String, dynamic> json) {
    return TopClaimProductModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? json['imageUrl'] ?? '').toString(),
      redeemPoints: (json['redeem_points'] as num?)?.toInt() ?? 0,
      companyName: (json['companyName'] ?? '').toString(),
    );
  }
}
