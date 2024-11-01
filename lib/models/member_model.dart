class MemberModel {
  final String name;
  final String office;
  final String id;
  final String? profileImage;

  MemberModel({
    required this.name,
    required this.office,
    required this.id,
    this.profileImage,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      name: json['name'] as String,
      office: json['office'] as String,
      id: json['_id'],
      profileImage: json['profileImage'] as String?,
    );
  }
}
