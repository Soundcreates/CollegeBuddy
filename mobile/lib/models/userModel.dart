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
      id: json['id'] as String,
      email: json['svv_email'] as String,
      name: json['name'] as String,
      profilePic: json['profile_pic'] as String,
      verifiedEmail: json['verified_email'] as bool,
    );
  }
}
