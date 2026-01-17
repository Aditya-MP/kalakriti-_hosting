import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'latest_artwork.dart';
import 'SearchPage.dart';

class RasikProfile extends StatefulWidget {
  const RasikProfile({super.key});

  @override
  RasikProfileState createState() => RasikProfileState();
}

class RasikProfileState extends State<RasikProfile> {
  // Project Artisan Palette
  final Color primaryEarth = const Color(0xFFE27D5F);
  final Color goldAccent = const Color(0xFFD4A574);
  final Color clayBg = const Color(0xFFF5F2E9);
  final Color deepHeritage = const Color(0xFF4A7043);

  File? _profileImage;
  String _name = "Art Admirer";
  String _bio = "Exploring Indian Crafts";
  String _about = "";
  String _profileImageUrl = "";

  final List<Map<String, String>> _favorites = [
    {"title": "Ceramic Soul", "artist": "Anika Verma", "image": "https://picsum.photos/400/300?random=10"},
    {"title": "Teak Elephant", "artist": "Rohan Kapoor", "image": "https://picsum.photos/400/300?random=11"},
    {"title": "Clay Journey", "artist": "Meera Patel", "image": "https://picsum.photos/400/300?random=12"},
  ];

  String? _uid;
  Stream<DocumentSnapshot>? _userDocStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _uid = user.uid;
      _userDocStream = FirebaseFirestore.instance.collection('users').doc(_uid).snapshots();
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) setState(() => _profileImage = File(pickedFile.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clayBg,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userDocStream,
        builder: (context, snapshot) {
          // Use default values, update only if Firebase data exists
          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            _name = data['showroomName'] ?? data['name'] ?? 'Art Admirer';
            _bio = data['bio'] ?? data['specialization'] ?? 'Exploring Indian Crafts';
            _profileImageUrl = data['profileImageUrl'] ?? data['showroomImage'] ?? '';
          }

          return CustomScrollView(
            slivers: [
              // Enhanced Profile Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("Rasik Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: deepHeritage)),
                        IconButton(icon: Icon(Icons.settings_outlined, color: deepHeritage), onPressed: () {}),
                      ]),
                      const SizedBox(height: 32),
                      Stack(
                        children: [
                          Container(
                            width: 130, height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: goldAccent, width: 3),
                              image: DecorationImage(
                                image: _profileImage != null 
                                  ? FileImage(_profileImage!) as ImageProvider
                                  : _profileImageUrl.isNotEmpty 
                                    ? NetworkImage(_profileImageUrl) 
                                    : const NetworkImage("https://picsum.photos/200?random=1"),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [BoxShadow(color: primaryEarth.withOpacity(0.2), blurRadius: 20)],
                            ),
                          ),
                          Positioned(bottom: 0, right: 0, child: InkWell(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8), 
                              decoration: BoxDecoration(
                                color: primaryEarth, 
                                shape: BoxShape.circle, 
                                border: Border.all(color: Colors.white, width: 2)
                              ), 
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18)
                            ),
                          )),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(_name, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: deepHeritage)),
                      const SizedBox(height: 4),
                      Text(_bio, style: TextStyle(fontSize: 16, color: primaryEarth)),
                      const SizedBox(height: 24),
                      SizedBox(width: double.infinity, child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16), 
                          side: BorderSide(color: goldAccent), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                        ),
                        child: Text("Edit Profile", style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold)),
                      )),
                    ],
                  ),
                ),
              ),
              // Favorites Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("My Favorites", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: deepHeritage)),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 24, right: 12),
                    itemCount: _favorites.length,
                    itemBuilder: (context, i) => _FavCard(fav: _favorites[i], color: primaryEarth, heritage: deepHeritage),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, currentIndex: 2,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LatestArtwork()));
          if (i == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SearchPage()));
        },
        selectedItemColor: deepHeritage, unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Studio'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Rasik'),
        ],
      ),
    );
  }
}

class _FavCard extends StatelessWidget {
  final Map<String, String> fav; 
  final Color color, heritage;
  
  const _FavCard({required this.fav, required this.color, required this.heritage});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160, 
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), 
            child: Image.network(
              fav["image"]!, 
              height: 120, 
              width: 160, 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                width: 160,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 40),
              ),
            )
          ),
          Padding(
            padding: const EdgeInsets.all(12), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(fav["title"]!, style: TextStyle(fontWeight: FontWeight.bold, color: heritage, fontSize: 14)),
                const SizedBox(height: 4),
                Text("By ${fav["artist"]!}", style: TextStyle(color: color, fontSize: 12)),
              ]
            )
          ),
        ]
      ),
    );
  }
}