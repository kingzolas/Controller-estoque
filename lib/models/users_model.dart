class UsersModel {
  final String id;
  final String name;
  final String email;
  final String password;
  final String oficcer;
  final DateTime createdAt;
  final DateTime updatedAt;

  UsersModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.oficcer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UsersModel.fromJson(Map<String, dynamic> json) {
    return UsersModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      oficcer: json['oficcer'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
