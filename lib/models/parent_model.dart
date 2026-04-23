class ParentModel {
  const ParentModel({
    required this.id,
    required this.name,
    this.email,
    required this.pin,
    this.createdAt,
  });

  final int id;
  final String name;
  final String? email;
  final String pin;
  final String? createdAt;

  factory ParentModel.fromMap(Map<String, dynamic> map) {
    return ParentModel(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String?,
      pin: map['pin'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'pin': pin,
      'created_at': createdAt,
    };
  }
}
