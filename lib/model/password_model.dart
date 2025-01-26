class Password {
  final String password;

  Password({
    required this.password,
  });

  factory Password.fromJson(Map<String, dynamic> json) {
    return Password(
      password: json['password'] as String,
    );
  }
}
