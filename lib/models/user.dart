class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? imageUrl;
  final String? specialty;
  final String? clinic;
  final int? experience;
  final String? price;
  final String? availability;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.imageUrl,
    this.specialty,
    this.clinic,
    this.experience,
    this.price,
    this.availability,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'patient',
      imageUrl: map['imageUrl'],
      specialty: map['specialty'],
      clinic: map['clinic'],
      experience: map['experience'],
      price: map['price'],
      availability: map['availability'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'imageUrl': imageUrl,
      if (specialty != null) 'specialty': specialty,
      if (clinic != null) 'clinic': clinic,
      if (experience != null) 'experience': experience,
      if (price != null) 'price': price,
      if (availability != null) 'availability': availability,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? imageUrl,
    String? specialty,
    String? clinic,
    int? experience,
    String? price,
    String? availability,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      imageUrl: imageUrl ?? this.imageUrl,
      specialty: specialty ?? this.specialty,
      clinic: clinic ?? this.clinic,
      experience: experience ?? this.experience,
      price: price ?? this.price,
      availability: availability ?? this.availability,
    );
  }
}
