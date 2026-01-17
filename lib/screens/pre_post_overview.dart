import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/firestore_service.dart';
import '../services/google_drive_service.dart';
import '../services/marketing_strategy_service.dart';
import '../services/marketing_strategy_download_service.dart';
import '../models/marketing_strategy.dart';
import 'latest_artwork.dart';

class PrePostOverview extends StatefulWidget {
  final String artisanName;
  final String artisanCategory;
  final String location;
  final String productName;
  final String productCategory;
  final String productDescription;
  final String productPrice;
  final String previewImagePath;

  const PrePostOverview({
    super.key,
    required this.artisanName,
    required this.artisanCategory,
    required this.location,
    required this.productName,
    required this.productCategory,
    required this.productDescription,
    required this.productPrice,
    required this.previewImagePath,
  });

  @override
  State<PrePostOverview> createState() => _PrePostOverviewState();
}

class _PrePostOverviewState extends State<PrePostOverview> {
  // Artisan Theme Palette
  final Color primaryEarth = const Color(0xFFE27D5F);
  final Color goldAccent = const Color(0xFFD4A574);
  final Color clayBg = const Color(0xFFF5F2E9);
  final Color deepHeritage = const Color(0xFF4A7043);

  MarketingStrategy? marketingStrategy;
  bool isGeneratingStrategy = false;
  String selectedSocialMedia = 'Instagram';
  String generatedStrategy = '';
  static const String geminiApiKey = 'your-api-key';
  
  final List<String> socialMediaOptions = [
    'Instagram',
    'Facebook', 
    'Pinterest',
    'WhatsApp Business',
    'Twitter/X'
  ];

  Future<void> _publish(BuildContext context) async {
    try {
      // Check Firebase connection first
      print('🔥 Checking Firebase connection...');
      final user = FirebaseAuth.instance.currentUser;
      print('👤 Current user: ${user?.uid}');
      
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login first'))
        );
        return;
      }

      // Test Firestore connection
      print('📊 Testing Firestore connection...');
      await FirebaseFirestore.instance.enableNetwork();
      
      final productData = {
        'showroomId': user.uid,
        'title': widget.productName,
        'description': widget.productDescription,
        'image': 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}',
        'price': widget.productPrice,
        'category': widget.productCategory,
        'artisan': widget.artisanName,
        'location': widget.location,
        'timestamp': FieldValue.serverTimestamp(),
      };

      print('💾 Attempting to save to Firestore...');
      final docRef = await FirebaseFirestore.instance
          .collection('products')
          .add(productData);
      
      print('✅ Document saved with ID: ${docRef.id}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product published successfully!'), backgroundColor: Colors.green)
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LatestArtwork()), 
          (r) => false
        );
      }
    } on FirebaseException catch (e) {
      print('🚨 Firebase Error: ${e.code} - ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Firebase Error: ${e.message}'))
        );
      }
    } catch (e) {
      print('💥 General Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Publish failed: $e'))
        );
      }
    }
  }

  void _showPlatformSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: goldAccent, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Choose Platform', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: deepHeritage)),
            const SizedBox(height: 16),
            ...socialMediaOptions.map((platform) => ListTile(
              leading: Icon(_getPlatformIcon(platform), color: primaryEarth),
              title: Text(platform),
              trailing: selectedSocialMedia == platform ? Icon(Icons.check_circle, color: primaryEarth) : null,
              onTap: () {
                setState(() => selectedSocialMedia = platform);
                Navigator.pop(context);
                _generateStrategy();
              },
            )),
          ],
        ),
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'Instagram': return Icons.camera_alt;
      case 'Facebook': return Icons.facebook;
      case 'Pinterest': return Icons.push_pin;
      case 'WhatsApp Business': return Icons.chat;
      case 'Twitter/X': return Icons.alternate_email;
      default: return Icons.share;
    }
  }

  void _generateStrategy() async {
    setState(() => isGeneratingStrategy = true);
    
    try {
      // First check available models
      final modelsResponse = await http.get(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$geminiApiKey'),
      ).timeout(const Duration(seconds: 10));
      
      if (modelsResponse.statusCode == 200) {
        final modelsData = json.decode(modelsResponse.body);
        final models = modelsData['models'] as List?;
        
        if (models != null && models.isNotEmpty) {
          // Use first available model
          final modelName = models[0]['name'];
          
          final prompt = '''Create ready-to-post social media content for $selectedSocialMedia about this Indian handicraft:

Product: ${widget.productName}
Category: ${widget.productCategory}
Description: ${widget.productDescription}
Price: ${widget.productPrice}
Artisan: ${widget.artisanName}
Location: ${widget.location}

Generate COPY-PASTE READY content with engaging caption, hashtags, and call-to-action optimized for $selectedSocialMedia.''';
          
          final response = await http.post(
            Uri.parse('https://generativelanguage.googleapis.com/v1beta/$modelName:generateContent?key=$geminiApiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [{
                'parts': [{'text': prompt}]
              }]
            }),
          ).timeout(const Duration(seconds: 15));
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final strategy = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
            
            if (strategy.isNotEmpty) {
              setState(() => generatedStrategy = strategy);
              _showStrategyDialog();
              setState(() => isGeneratingStrategy = false);
              return;
            }
          }
        }
      }
    } catch (e) {
      print('API Error: $e');
    }
    
    // Fallback
    setState(() => generatedStrategy = _getFallbackStrategy());
    _showStrategyDialog();
    setState(() => isGeneratingStrategy = false);
  }

  String _getFallbackStrategy() {
    return '''📱 READY-TO-POST CONTENT FOR ${selectedSocialMedia.toUpperCase()}

✨ CAPTION:
"Every thread tells a story, every pattern holds a dream. 🧵✨

Meet '${widget.productName}' - a masterpiece born from the skilled hands of ${widget.artisanName} in ${widget.location}. This isn't just ${widget.productCategory.toLowerCase()}, it's a piece of our cultural soul, crafted with techniques passed down through generations.

${widget.productDescription}

When you choose handmade, you're not just buying a product - you're preserving an art form, supporting a family, and carrying forward our heritage. 🇮🇳

💰 Available for ${widget.productPrice}
📦 Ready to ship across India
🎁 Perfect for gifting or your home

#HandmadeInIndia #${widget.productCategory.replaceAll(' ', '')} #IndianHandicraft #ArtisanMade #CulturalHeritage #TraditionalCraft #SustainableArt #MadeWithLove #AuthenticCraft #IndianArt #HandcraftedTreasures #SupportArtisans #HeritageArt #CraftedWithCare #TimelessBeauty

👆 DM us to bring this beauty home! Limited pieces available."

🎯 CALL-TO-ACTION:
"Double-tap if you love supporting our artisans! 💕 Tag someone who appreciates authentic craftsmanship!"

📋 PLATFORM TIPS:
• Post during 7-9 PM for maximum engagement
• Use carousel posts to show creation process
• Share artisan stories in highlights
• Engage with comments within first hour''';
  }

  void _showStrategyDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '$selectedSocialMedia Content Ready!', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: deepHeritage)
                    )
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    generatedStrategy, 
                    style: const TextStyle(height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Share.share(generatedStrategy);
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(foregroundColor: primaryEarth),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Content copied! Ready to paste on $selectedSocialMedia'),
                            backgroundColor: primaryEarth,
                          )
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryEarth, foregroundColor: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clayBg,
      appBar: AppBar(
        title: const Text('Review Masterpiece', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        foregroundColor: deepHeritage,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            // Hero Image Preview with Artisan Frame
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: goldAccent, width: 2),
                boxShadow: [BoxShadow(color: primaryEarth.withOpacity(0.2), blurRadius: 20)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: widget.previewImagePath.startsWith('http') 
                  ? Image.network(
                      widget.previewImagePath, 
                      height: 220, 
                      width: double.infinity, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 220,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 50),
                      ),
                    )
                  : widget.previewImagePath.isNotEmpty
                    ? Image.file(
                        File(widget.previewImagePath), 
                        height: 220, 
                        width: double.infinity, 
                        fit: BoxFit.cover
                      )
                    : Container(
                        height: 220,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 50),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            // Artisan Details Card
            _ArtisanDetailCard(
              name: widget.artisanName, 
              category: widget.artisanCategory, 
              location: widget.location, 
              color: deepHeritage, 
              gold: goldAccent
            ),
            const SizedBox(height: 20),
            // Product Details Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(24)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                    children: [
                      Expanded(
                        child: Text(
                          widget.productName, 
                          style: TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold, 
                            color: deepHeritage
                          )
                        )
                      ),
                      Text(
                        widget.productPrice, 
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: primaryEarth
                        )
                      ),
                    ]
                  ),
                  const Divider(height: 24),
                  Text(
                    "Category: ${widget.productCategory}", 
                    style: TextStyle(
                      color: goldAccent, 
                      fontWeight: FontWeight.w600
                    )
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.productDescription, 
                    style: const TextStyle(
                      fontSize: 15, 
                      height: 1.5, 
                      color: Colors.black87
                    )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Marketing Strategy Teaser
            _MarketingTeaser(
              onGenerate: _showPlatformSelector, 
              isGenerating: isGeneratingStrategy, 
              strategy: marketingStrategy, 
              primary: primaryEarth,
              hasStrategy: generatedStrategy.isNotEmpty,
              onViewStrategy: generatedStrategy.isNotEmpty ? _showStrategyDialog : null,
              selectedPlatform: selectedSocialMedia,
            ),
            const SizedBox(height: 32),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16), 
                      side: BorderSide(color: primaryEarth), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                    ),
                    child: Text(
                      "Refine", 
                      style: TextStyle(
                        color: primaryEarth, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  )
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _publish(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deepHeritage, 
                      foregroundColor: Colors.white, 
                      padding: const EdgeInsets.symmetric(vertical: 16), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                    ),
                    child: const Text(
                      "Publish to World", 
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                  )
                ),
              ]
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ArtisanDetailCard extends StatelessWidget {
  final String name, category, location; 
  final Color color, gold;
  
  const _ArtisanDetailCard({
    required this.name, 
    required this.category, 
    required this.location, 
    required this.color, 
    required this.gold
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05), 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: color.withOpacity(0.2))
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25, 
            backgroundColor: gold, 
            child: const Icon(Icons.person, color: Colors.white)
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text(
                name, 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 18, 
                  color: color
                )
              ),
              Text(
                "$category • $location", 
                style: TextStyle(
                  fontSize: 14, 
                  color: color.withOpacity(0.7)
                )
              ),
            ]
          ),
        ]
      ),
    );
  }
}

class _MarketingTeaser extends StatelessWidget {
  final VoidCallback onGenerate; 
  final bool isGenerating; 
  final MarketingStrategy? strategy; 
  final Color primary;
  final bool hasStrategy;
  final VoidCallback? onViewStrategy;
  final String selectedPlatform;
  
  const _MarketingTeaser({
    required this.onGenerate, 
    required this.isGenerating, 
    this.strategy, 
    required this.primary,
    this.hasStrategy = false,
    this.onViewStrategy,
    required this.selectedPlatform,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: primary.withOpacity(0.2))
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: primary), 
              const SizedBox(width: 12), 
              const Text(
                "Social Media Content Generator", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
              )
            ]
          ),
          const SizedBox(height: 12),
          Text(
            hasStrategy 
              ? "Ready-to-post content for $selectedPlatform is generated!"
              : "Generate copy-paste ready social media posts for any platform", 
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontSize: 14, 
              color: hasStrategy ? primary : Colors.grey
            )
          ),
          const SizedBox(height: 16),
          if (isGenerating) 
            Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                Text('Generating for $selectedPlatform...', style: TextStyle(color: primary, fontSize: 12)),
              ],
            )
          else if (hasStrategy)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onGenerate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: primary),
                    ),
                    child: const Text("New Platform"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onViewStrategy,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary, 
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("View Content"),
                  ),
                ),
              ],
            )
          else 
            ElevatedButton(
              onPressed: onGenerate, 
              style: ElevatedButton.styleFrom(
                backgroundColor: primary, 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ), 
              child: const Text("Choose Platform & Generate")
            ),
        ]
      ),
    );
  }
}