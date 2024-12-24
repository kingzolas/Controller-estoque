class UserModel {
  final String id;
  final String email;
  final String name;
  final String? oficcer;

  UserModel(
      {required this.id,
      required this.email,
      required this.name,
      this.oficcer});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json[
          'id'], // Certifique-se de que as chaves correspondem aos nomes no JSON
      email: json['email'],
      name: json['name'],
      oficcer: json['oficcer'] ?? '', // Pode ser null
    );
  }
}
