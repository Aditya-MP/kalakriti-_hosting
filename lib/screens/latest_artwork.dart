import 'package:flutter/material.dart';
import 'SearchPage.dart';
import 'depth0_frame0_screen.dart'; // Corrected import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'landing_screen.dart';
import 'rasik_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class LatestArtwork extends StatefulWidget {
  const LatestArtwork({super.key});

  @override
  State<LatestArtwork> createState() => _LatestArtworkState();
}

class _LatestArtworkState extends State<LatestArtwork> {
  int _selectedIndex = 0;

  void _onNavTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RasikProfile()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Method to handle product card tap
  void _onProductTap(Map<String, dynamic> productData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Depth0Frame0(productData: productData), // Corrected class name
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          cacheExtent: 800,
          children: [
            // Top bar with avatar and settings
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Row(
                children: [
                  // Avatar
                  ClipOval(
                    child: Image.network(
                      "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/6rzwd616_expires_30_days.png",
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.black54,
                      size: 26,
                    ),
                    onSelected: (value) async {
                      if (value == 'sign_out') {
                        await FirebaseAuth.instance.signOut();
                        if (!mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LandingScreen(),
                          ),
                          (route) => false,
                        );
                      } else if (value == 'delete_last_3') {
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;
                          final qs = await firestoreInstance
                              .collection('products')
                              .where('showroomId', isEqualTo: user.uid)
                              .orderBy('createdAt', descending: true)
                              .limit(3)
                              .get();
                          int deleted = 0;
                          for (final doc in qs.docs) {
                            final data = doc.data();
                            final List images = (data['images'] as List?) ?? [];
                            for (final img in images) {
                              final url = img is String ? img : '';
                              if (url.startsWith('http') && url.contains('firebasestorage')) {
                                try {
                                  await FirebaseStorage.instance.refFromURL(url).delete();
                                } catch (_) {}
                              }
                            }
                            await doc.reference.delete();
                            deleted++;
                          }
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Deleted $deleted post(s)')),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Delete failed: $e')),
                          );
                        }
                      }
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem<String>(
                          value: 'sign_out',
                          child: Text('Sign Out'),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete_last_3',
                          child: Text('Delete My Last 3 Posts'),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              child: Text(
                "Latest Artworks",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0,
                  color: Colors.black,
                ),
              ),
            ),
            // Dynamic: recently published products (newest first)
            StreamBuilder<QuerySnapshot>(
              stream: firestoreInstance
                  .collection('products')
                  // Single order avoids composite index requirement
                  .orderBy('createdAt', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox.shrink();
                }
                final docs = snapshot.data!.docs;
                return Column(
                  children: docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final List images = (data['images'] as List?) ?? [];
                    final String image = images.isNotEmpty && (images.first as String).isNotEmpty
                        ? (images.first as String)
                        : '';
                    final String title = (data['title'] ?? 'Untitled') as String;
                    final String desc = (data['description'] ?? '') as String;
                    final String artist = 'You';
                    return _artworkCard(
                      image: image.isNotEmpty
                          ? image
                          : "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/bm9srn9f_expires_30_days.png",
                      title: title,
                      desc: desc,
                      artist: artist,
                      likeCount: (data['likeCount'] ?? 0).toString(),
                      commentCount: (data['commentCount'] ?? 0).toString(),
                      iconLeft: Icons.favorite_border,
                      iconRight: Icons.bookmark_border,
                      onTap: () {
                        _onProductTap({
                          'image': image,
                          'title': title,
                          'desc': desc,
                          'artist': artist,
                          'likeCount': (data['likeCount'] ?? 0).toString(),
                          'commentCount': (data['commentCount'] ?? 0).toString(),
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 10),

            // Default sample cards (restored)
            _artworkCard(
              image: "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/bm9srn9f_expires_30_days.png",
              title: "Ceramic Vase",
              desc: "Handcrafted ceramic vase with intricate floral patterns.",
              artist: "Anya Sharma",
              likeCount: "234",
              commentCount: "120",
              iconLeft: Icons.favorite_border,
              iconRight: Icons.bookmark_border,
              onTap: () {
                _onProductTap({
                  'image': "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/bm9srn9f_expires_30_days.png",
                  'title': "Ceramic Vase",
                  'desc': "Handcrafted ceramic vase with intricate floral patterns.",
                  'artist': "Anya Sharma",
                  'likeCount': "234",
                  'commentCount': "120",
                });
              },
            ),
            _artworkCard(
              image: "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/dzofg6nq_expires_30_days.png",
              title: "Wooden Sculpture",
              desc: "Detailed wooden sculpture of a mythical creature.",
              artist: "Rohan Verma",
              likeCount: "187",
              commentCount: "95",
              iconLeft: Icons.favorite_border,
              iconRight: Icons.bookmark_border,
              onTap: () {
                _onProductTap({
                  'image': "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/dzofg6nq_expires_30_days.png",
                  'title': "Wooden Sculpture",
                  'desc': "Detailed wooden sculpture of a mythical creature.",
                  'artist': "Rohan Verma",
                  'likeCount': "187",
                  'commentCount': "95",
                });
              },
            ),
            _artworkCard(
              image: "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/kri0ziim_expires_30_days.png",
              title: "Embroidered Textile",
              desc: "Vibrant embroidered textile depicting a traditional scene.",
              artist: "Kavya Patel",
              likeCount: "210",
              commentCount: "112",
              iconLeft: Icons.favorite_border,
              iconRight: Icons.bookmark_border,
              onTap: () {
                _onProductTap({
                  'image': "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/kri0ziim_expires_30_days.png",
                  'title': "Embroidered Textile",
                  'desc': "Vibrant embroidered textile depicting a traditional scene.",
                  'artist': "Kavya Patel",
                  'likeCount': "210",
                  'commentCount': "112",
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 28),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 28),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _artworkCard({
    required String image,
    required String title,
    required String desc,
    required String artist,
    required String likeCount,
    required String commentCount,
    required IconData iconLeft,
    required IconData iconRight,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                image,
                height: 148,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) {
                  return Container(
                    height: 148,
                    width: double.infinity,
                    color: const Color(0xFFF0F0F0),
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              desc,
              style: const TextStyle(
                color: Color(0xFF757575),
                fontSize: 15.0,
                height: 1.4,
              ),
            ),
            Text(
              "by $artist",
              style: const TextStyle(
                color: Color(0xFF757575),
                fontSize: 15.0,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Icon(
                  iconLeft,
                  color: const Color(0xFFB0AAA4),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  likeCount,
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 20),
                Icon(
                  iconRight,
                  color: const Color(0xFFB0AAA4),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  commentCount,
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}