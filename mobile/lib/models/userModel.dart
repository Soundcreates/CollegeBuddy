class UserModel {
  final String id;
  final String email;
  final String name;
  final String profilePic;
  final bool verifiedEmail;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.profilePic,
    required this.verifiedEmail,
  });
  List<String> emails = [];

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      email: (json['svv_email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      profilePic: (json['profile_pic'] ?? '').toString(),
      verifiedEmail: json['verified_email'] ?? false,
    );
  }
}
