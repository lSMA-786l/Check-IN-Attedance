/// User Model
class UserModel {
  final String id;
  final String role; // EMPLOYEE, MANAGER, ADMIN
  final String name;
  final String? managerId;
  final String email;
  final String phone;
  final String? designation;
  final String? department;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.role,
    required this.name,
    this.managerId,
    required this.email,
    required this.phone,
    this.designation,
    this.department,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      role: json['role'] as String,
      name: json['name'] as String,
      managerId: json['managerId'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String,
      designation: json['designation'] as String?,
      department: json['department'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'name': name,
      'managerId': managerId,
      'email': email,
      'phone': phone,
      'designation': designation,
      'department': department,
      'avatarUrl': avatarUrl,
    };
  }
}
