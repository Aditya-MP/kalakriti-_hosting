import 'package:flutter/material.dart';
import 'SearchPage.dart';
import 'depth0_frame0_screen.dart'; 
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
  // Artisan Theme Palette
  final Color primaryEarth = const Color(0xFFE27D5F);
  final Color goldAccent = const Color(0xFFD4A574);
  final Color clayBg = const Color(0xFFF5F2E9);
  final Color deepHeritage = const Color(0xFF4A7043);

  int _selectedIndex = 0;

  void _onNavTapped(int index) {
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RasikProfile()));
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  void _onProductTap(Map<String, dynamic> productData) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Depth0Frame0(productData: productData)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clayBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Artisan Top Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: goldAccent, width: 2)),
                      child: const CircleAvatar(radius: 20, backgroundImage: NetworkImage("https://picsum.photos/150/150?random=1")),
                    ),
                    const SizedBox(width: 12),
                    Text("KalaKrithi", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: deepHeritage, letterSpacing: 0.5, shadows: [Shadow(color: goldAccent.withOpacity(0.3), offset: Offset(1, 1), blurRadius: 2)])),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.notifications_none, color: deepHeritage),
                      onPressed: () {},
                    ),
                    _buildSettingsMenu(),
                  ],
                ),
              ),
            ),
            // Hero Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [primaryEarth, goldAccent]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: primaryEarth.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: Stack(
                    children: [
                      Positioned(right: -20, bottom: -20, child: Icon(Icons.brush, size: 100, color: Colors.white.withOpacity(0.2))),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Discovery Gallery", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            Text("Support authentic Indian artisans", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8), child: Text("Latest Masterpieces", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))),
            // Dynamic Stream of Artworks
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('products').orderBy('timestamp', descending: true).limit(20).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SliverToBoxAdapter(child: Center(child: Text('No artworks yet')));
                
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final data = snapshot.data!.docs[index].data();
                      final String image = data['image'] ?? 'https://picsum.photos/400/300?random=2';
                      return _ArtCard(
                        image: image, 
                        title: data['title'] ?? 'Untitled', 
                        desc: data['description'] ?? '', 
                        artist: data['artisan'] ?? 'Master Artisan', 
                        likes: '0', 
                        primary: primaryEarth, 
                        gold: goldAccent, 
                        heritage: deepHeritage,
                        onTap: () => _onProductTap(<String, dynamic>{'image': image, 'title': data['title'], 'desc': data['description']}),
                      );
                    },
                    childCount: snapshot.data!.docs.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
        child: BottomNavigationBar(
          backgroundColor: Colors.white, currentIndex: _selectedIndex, onTap: _onNavTapped,
          selectedItemColor: deepHeritage, unselectedItemColor: Colors.grey, elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Studio'),
            BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Discover'),
            BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined), label: 'Rasik'),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, color: deepHeritage),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'sign_out', child: Text('Sign Out')),
        const PopupMenuItem(value: 'delete_last_3', child: Text('Manage Collection')),
      ],
      onSelected: (value) async {
        if (value == 'sign_out') {
          await FirebaseAuth.instance.signOut();
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LandingScreen()), (r) => false);
        }
      },
    );
  }
}

class _ArtCard extends StatelessWidget {
  final String image, title, desc, artist, likes; 
  final Color primary, gold, heritage; 
  final VoidCallback onTap;
  
  const _ArtCard({
    required this.image, 
    required this.title, 
    required this.desc, 
    required this.artist, 
    required this.likes, 
    required this.primary, 
    required this.gold, 
    required this.heritage, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), child: Image.network(image, height: 180, width: double.infinity, fit: BoxFit.cover)),
                Positioned(top: 16, right: 16, child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(Icons.favorite_border, color: primary, size: 20))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: heritage)),
                    Row(children: [Icon(Icons.remove_red_eye_outlined, size: 16, color: gold), const SizedBox(width: 4), Text(likes, style: const TextStyle(fontWeight: FontWeight.w600))]),
                  ]),
                  const SizedBox(height: 8),
                  Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], height: 1.4)),
                  const SizedBox(height: 12),
                  Row(children: [
                    CircleAvatar(radius: 12, backgroundColor: gold.withOpacity(0.2), child: Icon(Icons.person, size: 14, color: gold)),
                    const SizedBox(width: 8),
                    Text("by $artist", style: TextStyle(fontWeight: FontWeight.w600, color: heritage.withOpacity(0.8))),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}