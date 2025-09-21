class Showroom {
  final String id;
  final String name;
  final String artisanDetails;
  final String businessDetails;
  final DateTime createdAt;

  Showroom({
    this.id = '',
    required this.name,
    required this.artisanDetails,
    required this.businessDetails,
    required this.createdAt,
  });

  // Convert model to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'artisanDetails': artisanDetails,
      'businessDetails': businessDetails,
      'createdAt': createdAt,
    };
  }

  // Create model from Firestore document
  factory Showroom.fromMap(String id, Map<String, dynamic> map) {
    return Showroom(
      id: id,
      name: map['name'] ?? '',
      artisanDetails: map['artisanDetails'] ?? '',
      businessDetails: map['businessDetails'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}