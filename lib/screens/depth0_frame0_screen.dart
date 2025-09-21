import 'package:flutter/material.dart';
import 'package:kalakriti_2_0/screens/SocialLink.dart';

class Depth0Frame0 extends StatefulWidget {
  final VoidCallback? onLogout;
  final Map<String, dynamic>? productData;

  const Depth0Frame0({super.key, this.onLogout, this.productData});

  @override
  Depth0Frame0State createState() => Depth0Frame0State();
}

class Depth0Frame0State extends State<Depth0Frame0> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Carousel & Details with Share Icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        const Icon(Icons.share_outlined, color: Colors.black, size: 24),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: PageController(viewportFraction: 0.75),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          final images = [
                            widget.productData?['image'] ?? "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/bm9srn9f_expires_30_days.png",
                            "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80",
                            "https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80",
                          ];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                images[index],
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.productData?['title'] ?? "Handcrafted Ceramic Vase",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.productData?['desc'] ?? "This unique ceramic vase is handcrafted by artisan Anya Sharma, featuring intricate detailing and a smooth, matte finish. Perfect for displaying flowers or as a standalone art piece.",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              // About the Artist Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Meet The Makers",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ClipOval(
                          child: Image.network(
                            "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/6rzwd616_expires_30_days.png",
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Anya Sharma", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("Ceramic Artist", style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Anya Sharma is a renowned ceramic artist based in Jaipur, India. Her work is inspired by traditional Indian pottery and contemporary design, creating pieces that are both functional and artistic.",
                      style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hear From Them",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Column(
                          children: [
                            ClipOval(
                              child: Image.network(
                                "https://randomuser.me/api/portraits/women/44.jpg",
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text("Priya Patel", style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Column(
                          children: [
                            ClipOval(
                              child: Image.network(
                                "https://randomuser.me/api/portraits/men/46.jpg",
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text("Vikram Singh", style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.favorite_border, color: Color(0xFFB0AAA4)),
                    const SizedBox(width: 6),
                    const Text("12", style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 24),
                    const Icon(Icons.mode_comment_outlined, color: Color(0xFFB0AAA4)),
                    const SizedBox(width: 6),
                    const Text("2", style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to SocialLink page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SocialLink(
                            productId: widget.productData?['id'], // Pass product ID if available
                            artisanName: "Anya Sharma", // Pass actual artisan data
                            artisanEmail: "anya@example.com",
                            artisanAvatarUrl: "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/6rzwd616_expires_30_days.png",
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Inquire to Buy",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerReview({
    required String name,
    required String comment,
    required int rating,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 0; i < 5; i++)
                Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  color: i < rating ? Colors.amber : Colors.grey,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}