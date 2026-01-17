import 'package:flutter/material.dart';
import 'latest_artwork.dart';
import 'rasik_profile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  // Artisan Theme Palette
  final Color primaryEarth = const Color(0xFFE27D5F);
  final Color goldAccent = const Color(0xFFD4A574);
  final Color clayBg = const Color(0xFFF5F2E9);
  final Color deepHeritage = const Color(0xFF4A7043);

  String textField1 = '';
  late AnimationController _catAnimController;
  late Animation<Offset> _catOffsetAnimation;

  @override
  void initState() {
    super.initState();
    _catAnimController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _catOffsetAnimation = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: _catAnimController, curve: Curves.easeOut));
    _catAnimController.forward();
  }

  @override
  void dispose() {
    _catAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clayBg,
      appBar: AppBar(
        title: Text("Discover Crafts", style: TextStyle(color: deepHeritage, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar - Artisan Style
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                ),
                child: TextField(
                  onChanged: (v) => setState(() => textField1 = v),
                  decoration: InputDecoration(
                    hintText: "Search for artisans or crafts",
                    prefixIcon: Icon(Icons.search, color: goldAccent),
                    suffixIcon: Icon(Icons.mic_none, color: primaryEarth),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            // Animated Categories
            SlideTransition(
              position: _catOffsetAnimation,
              child: SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20, right: 10),
                  children: [
                    _buildCategoryBtn("Handloom"),
                    _buildCategoryBtn("Pottery"),
                    _buildCategoryBtn("Jewelry"),
                    _buildCategoryBtn("Woodwork"),
                    _buildCategoryBtn("Stonecraft"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Discovery Results
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _ArtisanSearchCard(
                    name: "Anjali Sharma", 
                    category: "Master Weaver", 
                    craft: "Handloom", 
                    image: "https://picsum.photos/400/300?random=20", 
                    color: deepHeritage, 
                    accent: goldAccent
                  ),
                  _ArtisanSearchCard(
                    name: "Rohan Verma", 
                    category: "Traditional Potter", 
                    craft: "Pottery", 
                    image: "https://picsum.photos/400/300?random=21", 
                    color: deepHeritage, 
                    accent: goldAccent
                  ),
                  _ArtisanSearchCard(
                    name: "Priya Kapoor", 
                    category: "Heritage Jeweler", 
                    craft: "Jewelry", 
                    image: "https://picsum.photos/400/300?random=22", 
                    color: deepHeritage, 
                    accent: goldAccent
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, currentIndex: 1,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LatestArtwork()));
          if (i == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RasikProfile()));
        },
        selectedItemColor: deepHeritage, unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Studio'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Rasik'),
        ],
      ),
    );
  }

  Widget _buildCategoryBtn(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: ActionChip(
        label: Text(label),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(color: deepHeritage, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), 
          side: BorderSide(color: goldAccent.withOpacity(0.3))
        ),
        onPressed: () {},
      ),
    );
  }
}

class _ArtisanSearchCard extends StatelessWidget {
  final String name, category, craft, image; 
  final Color color, accent;
  
  const _ArtisanSearchCard({
    required this.name, 
    required this.category, 
    required this.craft, 
    required this.image, 
    required this.color, 
    required this.accent
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)]
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(category, style: TextStyle(fontSize: 12, color: accent, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                Text(craft, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5F2E9), 
                    foregroundColor: color, 
                    elevation: 0, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: const Text("Visit Showroom", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ]
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20), 
            child: Image.network(
              image, 
              width: 120, 
              height: 120, 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 120,
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 40),
              ),
            )
          ),
        ],
      ),
    );
  }
}