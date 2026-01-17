import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:kalakriti_2_0/screens/latest_artwork.dart';

class _PlatformLink {
  final String keyName; // firestore key
  final String label;
  final String iconUrl; // optional network fallback
  final String assetPath; // preferred local asset path
  final String defaultUrl;
  const _PlatformLink(this.keyName, this.label, this.iconUrl, this.assetPath, this.defaultUrl);
}

class SocialLink extends StatefulWidget {
  final String? productId; // if provided, links are saved/loaded on this product
  final String? artisanName;
  final String? artisanEmail;
  final String? artisanAvatarUrl;
  const SocialLink({super.key, this.productId, this.artisanName, this.artisanEmail, this.artisanAvatarUrl});
  @override
  SocialLinkState createState() => SocialLinkState();
}

class SocialLinkState extends State<SocialLink> {
  final List<_PlatformLink> _platforms = const [
    _PlatformLink('amazon', 'Amazon Karigar', 'https://upload.wikimedia.org/wikipedia/commons/a/a9/Amazon_logo.svg', 'assets/icons/amazon.png', 'https://www.amazon.in/karigar'),
    _PlatformLink('flipkartSamarth', 'Flipkart Samarth', 'https://upload.wikimedia.org/wikipedia/commons/1/1b/Flipkart_logo.png', 'assets/icons/flipkart.png', 'https://www.flipkart.com/samarth'),
    _PlatformLink('meesho', 'Meesho', 'https://meesho.com/images/meta/favicon.ico', 'assets/icons/meesho.png', 'https://www.meesho.com/'),
    _PlatformLink('pinterest', 'Pinterest', 'https://s.pinimg.com/webapp/style/images/favicon.png', 'assets/icons/pinterest.png', 'https://www.pinterest.com/'),
    _PlatformLink('instagram', 'Instagram', 'https://upload.wikimedia.org/wikipedia/commons/a/a5/Instagram_icon.png', 'assets/icons/instagram.png', 'https://www.instagram.com/'),
    _PlatformLink('facebook', 'Facebook', 'https://upload.wikimedia.org/wikipedia/commons/1/1b/Facebook_icon.svg', 'assets/icons/facebook.png', 'https://www.facebook.com/'),
  ];

  Map<String, String> _links = {}; // loaded/saved links

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    if (widget.productId == null) return;
    try {
  final doc = await firestoreInstance.collection('products').doc(widget.productId).get();
      final data = doc.data();
      if (data != null && data['links'] is Map<String, dynamic>) {
        setState(() {
          _links = (data['links'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v.toString()));
        });
      }
    } catch (_) {}
  }

  Future<void> _openOrAddLink(_PlatformLink p) async {
    final saved = _links[p.keyName];
    if (saved != null && saved.isNotEmpty) {
      final uri = Uri.tryParse(saved);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    // Ask user to add link (keeps UI same, uses dialog)
    final controller = TextEditingController(text: saved ?? p.defaultUrl);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add ${p.label} link'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(hintText: 'https://example.com/your-page'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    if (widget.productId != null) {
  await firestoreInstance.collection('products').doc(widget.productId).set({
        'links': {p.keyName: result},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      setState(() => _links[p.keyName] = result);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link saved')));
    } else {
      final uri = Uri.tryParse(result);
      if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Method to show navigation dialog
  void _showNavigationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Navigate to"),
          content: const Text("Do you want to go to the home page or stay here?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                // Navigate to Latest Artwork page and remove all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LatestArtwork()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text("Home Page"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Just close the dialog
              },
              child: const Text("Stay Here"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Social Links'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: _showNavigationDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          color: const Color(0xFFFFFFFF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (as in design)
              Container(
                height: 140,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFF7F7F7),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6))],
                ),
                child: Row(children: [
                  const SizedBox(width: 16),
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      widget.artisanAvatarUrl ?? 'https://picsum.photos/400/300',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.artisanName ?? 'Artisan Name',
                          style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.artisanEmail ?? 'artisan.email@email.com',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                ]),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Available On', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: _platforms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final p = _platforms[index];
                    final link = _links[p.keyName];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8ECF3)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: Row(
                        children: [
                          _logo(p),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(p.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                              const SizedBox(height: 2),
                              Text(
                                link ?? 'No link provided',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: link == null ? Colors.grey : Colors.blueGrey),
                              ),
                            ]),
                          ),
                          const SizedBox(width: 6),
                          if (link != null)
                            IconButton(
                              tooltip: 'Copy',
                              icon: const Icon(Icons.copy, color: Colors.grey),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: link));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied')));
                              },
                            ),
                          IconButton(
                            tooltip: link == null ? 'Add link' : 'Open',
                            icon: const Icon(Icons.open_in_new, color: Color(0xFF5B86E5)),
                            onPressed: () => _openOrAddLink(p),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo(_PlatformLink p) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        p.assetPath,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Image.network(
            p.iconUrl,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.store_mall_directory),
          );
        },
      ),
    );
  }
}

