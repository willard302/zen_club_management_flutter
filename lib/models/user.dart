/// 用户模型
class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? studentId;
  final String? phone;
  final String? gender;
  final String? department;
  final String? grade;
  final DateTime? birthday;
  final String? avatarUrl;
  final String? lineId;
  final String? instagram;
  final String? hierarchy;
  final String? clubRole;
  final String? clubGroup;
  final String? inviter;
  final DateTime? joinDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.studentId,
    this.phone,
    this.gender,
    this.department,
    this.grade,
    this.birthday,
    this.avatarUrl,
    this.lineId,
    this.instagram,
    this.hierarchy,
    this.clubRole,
    this.clubGroup,
    this.inviter,
    this.joinDate,
    required this.createdAt,
    this.updatedAt,
  });

  /// 从 JSON 创建 User 对象
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String? ?? json['club_role'] as String? ?? '会员',
      studentId: json['student_id'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      department: json['department'] as String?,
      grade: json['grade'] as String?,
      birthday: json['birthday'] != null ? DateTime.parse(json['birthday'] as String) : null,
      avatarUrl: json['avatar_url'] as String?,
      lineId: json['line_id'] as String?,
      instagram: json['instagram'] as String?,
      hierarchy: json['hierarchy'] as String?,
      clubRole: json['club_role'] as String?,
      clubGroup: json['club_group'] as String?,
      inviter: json['inviter'] as String?,
      joinDate: json['join_date'] != null ? DateTime.parse(json['join_date'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'student_id': studentId,
      'phone': phone,
      'gender': gender,
      'department': department,
      'grade': grade,
      'birthday': birthday?.toIso8601String(),
      'avatar_url': avatarUrl,
      'line_id': lineId,
      'instagram': instagram,
      'hierarchy': hierarchy,
      'club_role': clubRole,
      'club_group': clubGroup,
      'inviter': inviter,
      'join_date': joinDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 复制对象并修改某些字段
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? studentId,
    String? phone,
    String? gender,
    String? department,
    String? grade,
    DateTime? birthday,
    String? avatarUrl,
    String? lineId,
    String? instagram,
    String? hierarchy,
    String? clubRole,
    String? clubGroup,
    String? inviter,
    DateTime? joinDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      studentId: studentId ?? this.studentId,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      department: department ?? this.department,
      grade: grade ?? this.grade,
      birthday: birthday ?? this.birthday,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lineId: lineId ?? this.lineId,
      instagram: instagram ?? this.instagram,
      hierarchy: hierarchy ?? this.hierarchy,
      clubRole: clubRole ?? this.clubRole,
      clubGroup: clubGroup ?? this.clubGroup,
      inviter: inviter ?? this.inviter,
      joinDate: joinDate ?? this.joinDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
