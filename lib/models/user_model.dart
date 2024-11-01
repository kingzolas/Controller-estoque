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
}
