import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../services/firestore_service.dart';
import 'latest_artwork.dart';

class SocialLink extends StatefulWidget {
  final String? productId, artisanName, artisanEmail, artisanAvatarUrl;
  const SocialLink({super.key, this.productId, this.artisanName, this.artisanEmail, this.artisanAvatarUrl});

  @override
  SocialLinkState createState() => SocialLinkState();
}

class SocialLinkState extends State<SocialLink> {
  final Color primaryEarth = const Color(0xFFE27D5F);
  final Color goldAccent = const Color(0xFFD4A574);
  final Color clayBg = const Color(0xFFF5F2E9);
  final Color deepHeritage = const Color(0xFF4A7043);

  final List<Marketplace> marketplaces = [
    Marketplace("Amazon Karigar", Icons.shopping_bag, "https://www.amazon.in/karigar", Color(0xFFE27D5F)),
    Marketplace("Flipkart Samarth", Icons.local_mall, "https://www.flipkart.com/samarth", Color(0xFFD4A574)),
    Marketplace("Meesho Artisan", Icons.storefront, "https://www.meesho.com/", Color(0xFF4A7043)),
    Marketplace("Instagram Shop", Icons.camera_alt, "https://www.instagram.com/", Color(0xFFE27D5F)),
    Marketplace("WhatsApp Orders", Icons.message, "https://wa.me/", Color(0xFFD4A574)),
    Marketplace("Direct Contact", Icons.phone, "tel:", Color(0xFF4A7043)),
  ];

  Map<String, String> _links = {};

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    if (widget.productId == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('products').doc(widget.productId).get();
      final data = doc.data();
      if (data != null && data['marketplaceLinks'] is Map) {
        setState(() => _links = Map<String, String>.from(data['marketplaceLinks']));
      }
    } catch (_) {}
  }

  Future<void> _toggleLink(Marketplace marketplace) async {
    final currentLink = _links[marketplace.key];
    if (currentLink != null && currentLink.isNotEmpty) {
      final uri = Uri.parse(currentLink);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showLinkDialog(marketplace);
    }
  }

  void _showLinkDialog(Marketplace marketplace) {
    final controller = TextEditingController(text: marketplace.defaultLink);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("${marketplace.name} Link", style: TextStyle(color: deepHeritage, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: marketplace.hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(marketplace.icon, color: marketplace.color),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final link = controller.text.trim();
              if (link.isEmpty) return;
              
              Navigator.pop(ctx, link);
              if (widget.productId != null) {
                await FirebaseFirestore.instance.collection('products').doc(widget.productId).set({
                  'marketplaceLinks.${marketplace.key}': link,
                  'linksUpdatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));
                setState(() => _links[marketplace.key] = link);
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${marketplace.name} saved!"), backgroundColor: Colors.green));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: marketplace.color),
            child: const Text("Save & Open", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clayBg,
      appBar: AppBar(
        title: const Text("Artisan Marketplace", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: deepHeritage,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LatestArtwork())),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.white, Colors.white.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 25, offset: const Offset(0, 12))],
            ),
            child: Row(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: goldAccent, width: 3),
                    image: DecorationImage(
                      image: NetworkImage(widget.artisanAvatarUrl ?? "https://picsum.photos/200/200?random=artisan"),
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
                      Text(widget.artisanName ?? "Artisan Master", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: deepHeritage)),
                      Text(widget.artisanEmail ?? "Contact via WhatsApp", style: TextStyle(fontSize: 16, color: primaryEarth)),
                      const SizedBox(height: 8),
                      Text("6 Active Marketplaces", style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: marketplaces.length,
              itemBuilder: (context, i) {
                final marketplace = marketplaces[i];
                final link = _links[marketplace.key];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: marketplace.color.withOpacity(0.2)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12)],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(20),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: marketplace.color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                      child: Icon(marketplace.icon, color: marketplace.color, size: 28),
                    ),
                    title: Text(marketplace.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: deepHeritage)),
                    subtitle: link != null
                        ? Text(link, style: TextStyle(color: Colors.grey[600], fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)
                        : Text("Tap to add your ${marketplace.name} link", style: TextStyle(color: Colors.grey[500])),
                    trailing: link != null
                        ? Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                              tooltip: "Copy",
                              icon: Icon(Icons.copy, size: 18, color: Colors.grey),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: link));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link copied!")));
                              },
                            ),
                            IconButton(
                              tooltip: "Open",
                              icon: Icon(Icons.open_in_new, color: marketplace.color),
                              onPressed: () => launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication),
                            ),
                          ])
                        : Icon(Icons.add_circle_outline, color: marketplace.color, size: 28),
                    onTap: () => _toggleLink(marketplace),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Marketplace {
  final String name, key, defaultLink, hint;
  final IconData icon;
  final Color color;
  const Marketplace(this.name, this.icon, this.defaultLink, this.color)
      : key = name.toLowerCase().replaceAll(' ', ''),
            hint = "your$name.com/profile";
}