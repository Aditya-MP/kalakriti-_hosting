import 'package:cloud_firestore/cloud_firestore.dart';

class ShowroomRegistration {
  String? id;
  final String artistName;
  final String artistStory;
  final String businessName;
  final String businessEmail;
  final String businessPhone;
  final String? profileImageUrl;
  final DateTime createdAt;

  ShowroomRegistration({
    this.id,
    required this.artistName,
    required this.artistStory,
    required this.businessName,
    required this.businessEmail,
    required this.businessPhone,
    this.profileImageUrl,
    required this.createdAt,
  });

  // Convert model to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'artistName': artistName,
      'artistStory': artistStory,
      'businessName': businessName,
      'businessEmail': businessEmail,
      'businessPhone': businessPhone,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
    };
  }

  // Create model from Firestore document
  factory ShowroomRegistration.fromMap(Map<String, dynamic> map, String id) {
    return ShowroomRegistration(
      id: id,
      artistName: map['artistName'] ?? '',
      artistStory: map['artistStory'] ?? '',
      businessName: map['businessName'] ?? '',
      businessEmail: map['businessEmail'] ?? '',
      businessPhone: map['businessPhone'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}