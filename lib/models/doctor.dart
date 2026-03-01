class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String clinic;
  final String imageUrl;
  final double rating;
  final int reviews;
  final int experience;
  final String nextAvailable;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.clinic,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.experience,
    required this.nextAvailable,
  });

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['_id']?.toString() ?? '',
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? 'General',
      clinic: map['clinic'] ?? 'Not specified',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviews: map['reviews'] ?? 0,
      experience: map['experience'] ?? 0,
      nextAvailable: map['nextAvailable'] ?? 'Not set',
    );
  }
}
