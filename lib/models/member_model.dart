class MemberModel {
  final String name;
  final String office;
  final String id;
  final String? profileImage;
  bool? isActive;

  MemberModel({
    required this.name,
    required this.office,
    required this.id,
    this.profileImage,
    this.isActive,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      name: json['name'] as String,
      office: json['office'],
      id: json['_id'],
      profileImage: json['profileImage'],
      isActive: json['isActive'],
    );
  }
}
