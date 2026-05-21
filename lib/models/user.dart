class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? securityQuestion;
  final String? securityAnswer;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.securityQuestion,
    this.securityAnswer,
  });

  // Convert UserModel to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'security_question': securityQuestion,
      'security_answer': securityAnswer,
    };
  }

  // Create UserModel from database Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      securityQuestion: map['security_question'],
      securityAnswer: map['security_answer'],
    );
  }
}