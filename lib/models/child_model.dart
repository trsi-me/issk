class ChildModel {
  const ChildModel({
    required this.id,
    required this.parentId,
    required this.name,
    this.age,
    required this.pin,
    this.status = 'active',
    this.createdAt,
  });

  final int id;
  final int parentId;
  final String name;
  final int? age;
  final String pin;
  /// active | suspended
  final String status;
  final String? createdAt;

  bool get isActive => status == 'active';

  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'] as int,
      parentId: (map['parent_id'] as int?) ?? 1,
      name: map['name'] as String,
      age: map['age'] as int?,
      pin: map['pin'] as String,
      status: (map['status'] as String?) ?? 'active',
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'name': name,
      'age': age,
      'pin': pin,
      'status': status,
      'created_at': createdAt,
    };
  }
}
