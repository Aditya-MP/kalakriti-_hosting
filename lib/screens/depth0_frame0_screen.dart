import 'package:flutter/material.dart';
import 'SocialLink.dart';

class Depth0Frame0 extends StatefulWidget {
  final VoidCallback? onLogout;
  final Map? productData;
  const Depth0Frame0({super.key, this.onLogout, this.productData});

  @override
  Depth0Frame0State createState() => Depth0Frame0State();
}

class Depth0Frame0State extends State<Depth0Frame0> {
  // Artisan Theme Palette
  final Color primaryEarth = const Color(0xFFE27D5F);
  final Color goldAccent = const Color(0xFFD4A574);
  final Color clayBg = const Color(0xFFF5F2E9);
  final Color deepHeritage = const Color(0xFF4A7043);

  int currentImageIndex = 0;
  PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = [
      widget.productData?['image'] ?? "https://picsum.photos/600/400?random=30",
      "https://picsum.photos/600/400?random=31",
      "https://picsum.photos/600/400?random=32",
    ];

    return Scaffold(
      backgroundColor: clayBg,
      body: CustomScrollView(
        slivers: [
          // Hero Image Sliver App Bar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: deepHeritage,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product_${widget.productData?['id'] ?? 'hero'}',
                    child: Image.network(
                      images[currentImageIndex], 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 100, color: Colors.grey),
                      ),
                    ),
                  ),
                  // Image Indicators
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentImageIndex == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentImageIndex == i ? Colors.white : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Product Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.productData?['title'] ?? "Handcrafted Terracotta Vase",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: deepHeritage),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.productData?['desc'] ?? "Handcrafted by Anya Sharma in Jaipur, this terracotta vase features intricate hand-painted motifs inspired by Rajasthan's heritage. Each piece tells a story of tradition and craftsmanship.",
                    style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 40),
                  // Artisan Spotlight
                  Text("The Master Artisan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: deepHeritage)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: goldAccent.withOpacity(0.2)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 70, 
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: const NetworkImage("https://picsum.photos/200?random=40"), 
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {},
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Anya Sharma", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: deepHeritage)),
                              Text("3rd Gen Potter • Jaipur", style: TextStyle(fontSize: 14, color: primaryEarth, fontWeight: FontWeight.w600)),
                              Text("Handcrafts 12 unique pieces monthly using traditional wheel techniques.", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Engagement Metrics
                  Row(
                    children: [
                      _MetricCard(icon: Icons.favorite, count: "127", label: "Loved", color: primaryEarth),
                      const SizedBox(width: 16),
                      _MetricCard(icon: Icons.comment, count: "23", label: "Stories", color: goldAccent),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Inquiry Button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (_) => SocialLink(productId: widget.productData?['id']))
                      ),
                      icon: const Icon(Icons.contact_support, color: Colors.white),
                      label: const Text("Inquiry to Buy", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: deepHeritage,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon; 
  final String count, label; 
  final Color color;
  
  const _MetricCard({required this.icon, required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    const Color deepHeritage = Color(0xFF4A7043);
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12)],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: deepHeritage)),
            Text(label, style: TextStyle(fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }
}