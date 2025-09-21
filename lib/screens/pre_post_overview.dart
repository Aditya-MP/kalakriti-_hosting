import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/google_drive_service.dart';
import '../services/firestore_service.dart';
import '../services/marketing_strategy_service.dart';
import '../services/marketing_strategy_download_service.dart';
import '../models/marketing_strategy.dart';
import 'package:share_plus/share_plus.dart';
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
  MarketingStrategy? marketingStrategy;
  bool isGeneratingStrategy = false;
  String selectedSocialMedia = 'Gaatha'; // Default selection

  Future<void> _publish(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to publish.')),
        );
        return;
      }

      // Upload image if it's a local file
      String imageUrl = widget.previewImagePath;
      final isLocal = !widget.previewImagePath.startsWith('http');
      if (isLocal) {
        final file = File(widget.previewImagePath);
        if (await file.exists()) {
          try {
            final ref = FirebaseStorage.instance
                .ref()
                .child('products/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
            final snapshot = await ref.putFile(
              file,
              SettableMetadata(contentType: 'image/jpeg'),
            );
            // Ensure server finished creating object before URL request
            await snapshot.ref.getMetadata();
            imageUrl = await ref.getDownloadURL();
          } catch (e) {
            // If upload fails, leave image empty; UI will show a local placeholder
            debugPrint('Storage upload failed: $e');
            imageUrl = '';
          }
        } else {
          debugPrint('Local file not found at ${widget.previewImagePath}');
          imageUrl = '';
        }
      }

      // Build product data
      final List<String> tags = widget.productCategory
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final productData = {
        'showroomId': user.uid,
        'title': widget.productName,
        'description': widget.productDescription,
        'images': [imageUrl],
        'price': double.tryParse(widget.productPrice.replaceAll(RegExp('[^0-9.]'), '')) ?? 0,
        'tags': tags,
        // Both server and client timestamps to ensure immediate ordering locally
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtMs': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': FieldValue.serverTimestamp(),
        'likeCount': 0,
        'commentCount': 0,
      };

  final productRef = await firestoreInstance.collection('products').add(productData);
      await AppDb.logActivity(type: 'publish', payload: {
        'productId': productRef.id,
        'title': widget.productName,
      });

      // Increment productsListed
  await firestoreInstance
          .collection('showrooms')
          .doc(user.uid)
          .set({'stats': {'productsListed': FieldValue.increment(1)}}, SetOptions(merge: true));

      // Optionally upload to the user's Google Drive as well (non-blocking)
      try {
        if (isLocal) {
          final drive = GoogleDriveService();
          // Fire and forget, don't await to keep UX responsive
          // ignore: unawaited_futures
          drive.signInWithGoogle().then((_) => drive.uploadFile(File(widget.previewImagePath)));
        }
      } catch (_) {}

      if (mounted) {
        // Navigate directly to Latest Artwork so the new post is visible immediately
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LatestArtwork()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Publish failed: $e')),
      );
    }
  }

  Future<void> _generateMarketingStrategy() async {
    setState(() {
      isGeneratingStrategy = true;
    });

    try {
      final strategy = await MarketingStrategyService.generateStrategy(
        productName: widget.productName,
        productCategory: widget.productCategory,
        productDescription: widget.productDescription,
        socialMediaPlatform: selectedSocialMedia,
      );

      setState(() {
        marketingStrategy = strategy;
        isGeneratingStrategy = false;
      });
    } catch (e) {
      setState(() {
        isGeneratingStrategy = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate marketing strategy: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildMarketingStrategy() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rocket_launch, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Marketing Strategy for Your Product',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Social Media Platform Selection
            if (marketingStrategy == null && !isGeneratingStrategy) ...[
              Text(
                'Choose Social Media Platform:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _buildSocialMediaSelector(),
              const SizedBox(height: 16),
            ],
            
            if (isGeneratingStrategy)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(
                      'Generating $selectedSocialMedia strategy...',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Creating personalized content ideas for your craft',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else if (marketingStrategy != null)
              _buildStrategyContent()
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generateMarketingStrategy,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text('Generate $selectedSocialMedia Strategy'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDownloadOptions() async {
    if (marketingStrategy == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Download Marketing Strategy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getPlatformColor(),
              ),
            ),
            const SizedBox(height: 20),
            
            // PDF Download
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('PDF Document'),
              subtitle: const Text('Professional document for printing'),
              onTap: () {
                Navigator.pop(context);
                _downloadPDF();
              },
            ),
            
            // Text Strategy Download
            ListTile(
              leading: Icon(Icons.text_fields, color: Colors.blue),
              title: const Text('Text Strategy'),
              subtitle: const Text('Formatted text for sharing'),
              onTap: () {
                Navigator.pop(context);
                _downloadTextStrategy();
              },
            ),
            
            // Share Options
            ListTile(
              leading: Icon(Icons.share, color: Colors.green),
              title: const Text('Share Strategy'),
              subtitle: const Text('Share via WhatsApp, Instagram, etc.'),
              onTap: () {
                Navigator.pop(context);
                _shareStrategy();
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPDF() async {
    if (marketingStrategy == null) return;
    
    try {
      await MarketingStrategyDownloadService.generatePDF(
        strategy: marketingStrategy!,
        platform: selectedSocialMedia,
        productName: widget.productName,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadTextStrategy() async {
    if (marketingStrategy == null) return;
    
    try {
      await MarketingStrategyDownloadService.generateTextStrategy(
        strategy: marketingStrategy!,
        platform: selectedSocialMedia,
        productName: widget.productName,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Text strategy shared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Text sharing failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareStrategy() async {
    if (marketingStrategy == null) return;
    
    try {
      final strategyText = '''
🎯 Marketing Strategy for $selectedSocialMedia

📸 Content Ideas:
${marketingStrategy!.contentIdeas.map((idea) => '• $idea').join('\n')}

 HASHTAGS:
${marketingStrategy!.hashtags.join(' ')}

⏰ Best Posting Times:
${marketingStrategy!.postingTimes}

💰 Pricing Strategies:
${marketingStrategy!.pricingStrategies.map((strategy) => '• $strategy').join('\n')}

🎯 Engagement Tactics:
${marketingStrategy!.engagementTactics.map((tactic) => '• $tactic').join('\n')}

Generated by Kalakriti - Empowering Artisans
''';

      await Share.share(
        strategyText,
        subject: 'Marketing Strategy for $selectedSocialMedia - ${widget.productName}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStrategyContent() {
    if (marketingStrategy == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Platform Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getPlatformColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getPlatformColor().withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(_getPlatformIcon(), color: _getPlatformColor(), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Strategy for $selectedSocialMedia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getPlatformColor(),
                      ),
                    ),
                    Text(
                      marketingStrategy!.rawResponse.contains('Fallback') 
                          ? 'Using curated strategy (API unavailable)'
                          : 'AI-generated real-time strategy',
                      style: TextStyle(
                        fontSize: 12,
                        color: marketingStrategy!.rawResponse.contains('Fallback') 
                            ? Colors.orange[700]
                            : Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Content Ideas
        _buildStrategySection(
          '📸 Content Ideas for $selectedSocialMedia',
          marketingStrategy!.contentIdeas,
          Colors.blue,
        ),
        const SizedBox(height: 16),
        
        // Hashtags
        _buildHashtagsSection(),
        const SizedBox(height: 16),
        
        // Posting Times
        _buildStrategySection(
          '⏰ Best Posting Times on $selectedSocialMedia',
          [marketingStrategy!.postingTimes],
          Colors.green,
        ),
        const SizedBox(height: 16),
        
        // Pricing Strategies
        _buildStrategySection(
          '💰 Pricing Strategies for $selectedSocialMedia',
          marketingStrategy!.pricingStrategies,
          Colors.orange,
        ),
        const SizedBox(height: 16),
        
        // Engagement Tactics
        _buildStrategySection(
          '🎯 Engagement Tactics for $selectedSocialMedia',
          marketingStrategy!.engagementTactics,
          Colors.purple,
        ),
        const SizedBox(height: 16),
        
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _generateMarketingStrategy,
                icon: const Icon(Icons.refresh),
                label: const Text('Regenerate'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showDownloadOptions(),
                icon: const Icon(Icons.download),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getPlatformColor(),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStrategySection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              Expanded(child: Text(item)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildSocialMediaSelector() {
    final List<Map<String, dynamic>> socialMediaOptions = [
      {'name': 'Gaatha', 'icon': Icons.book, 'color': Colors.orange, 'description': 'Storytelling-based craft platform'},
      {'name': 'Flipkart Samarth', 'icon': Icons.store, 'color': Colors.blue, 'description': 'Flipkart\'s platform for handicrafts'},
      {'name': 'Pinterest', 'icon': Icons.push_pin, 'color': Colors.redAccent, 'description': 'Visual inspiration, craft discovery'},
      {'name': 'Instagram', 'icon': Icons.camera_alt, 'color': Colors.pink, 'description': 'Visual storytelling, reels for crafts'},
      {'name': 'Facebook', 'icon': Icons.facebook, 'color': Colors.blue, 'description': 'Pages, groups, community reach'},
    ];

    print('🔍 Social Media Options Count: ${socialMediaOptions.length}');
    for (var option in socialMediaOptions) {
      print('📱 Option: ${option['name']}');
    }

    return Column(
      children: [
        Text(
          'Available Platforms:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: socialMediaOptions.map((option) {
            final isSelected = selectedSocialMedia == option['name'];
            print('🎯 Rendering option: ${option['name']}, Selected: $isSelected');
            return GestureDetector(
              onTap: () {
                print('👆 Tapped on: ${option['name']}');
                setState(() {
                  selectedSocialMedia = option['name'];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? (option['color'] as Color).withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? option['color'] as Color
                        : Colors.grey.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      option['icon'] as IconData,
                      color: isSelected ? option['color'] as Color : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      option['name'] as String,
                      style: TextStyle(
                        color: isSelected ? option['color'] as Color : Colors.grey,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getPlatformColor() {
    switch (selectedSocialMedia.toLowerCase()) {
      case 'gaatha':
        return Colors.orange;
      case 'flipkart samarth':
        return Colors.blue;
      case 'pinterest':
        return Colors.redAccent;
      case 'instagram':
        return Colors.pink;
      case 'facebook':
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  IconData _getPlatformIcon() {
    switch (selectedSocialMedia.toLowerCase()) {
      case 'gaatha':
        return Icons.book;
      case 'flipkart samarth':
        return Icons.store;
      case 'pinterest':
        return Icons.push_pin;
      case 'instagram':
        return Icons.camera_alt;
      case 'facebook':
        return Icons.facebook;
      default:
        return Icons.rocket_launch;
    }
  }

  Widget _buildHashtagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          ' Hashtags',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.pink,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: marketingStrategy!.hashtags.map((hashtag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.pink.withOpacity(0.3)),
            ),
            child: Text(
              hashtag,
              style: const TextStyle(
                color: Colors.pink,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLocalFile = !widget.previewImagePath.startsWith('http');
    final String normalizedCategory = widget.productCategory.trim();
    final bool showCategory = normalizedCategory.isNotEmpty &&
        normalizedCategory.toLowerCase() != widget.productName.trim().toLowerCase() &&
        normalizedCategory.toLowerCase() != 'ceramic, paint';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Post'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image preview
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: isLocalFile
                    ? Image.file(
                        File(widget.previewImagePath),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        widget.previewImagePath,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 30),
              // Artisan Info section
              Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        'https://img.icons8.com/ios-filled/50/000000/user-male-circle.png'),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.artisanName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Text(
                        widget.artisanCategory,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        widget.location,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Product Details
              const Text("Product Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 10),
              Text(
                widget.productName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              if (showCategory)
                Text(
                  widget.productCategory,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              const SizedBox(height: 15),
              Text(
                widget.productDescription,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              
              // Marketing Strategy Section
              _buildMarketingStrategy(),
              
              const SizedBox(height: 20),
              // Buttons: Back and Publish
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back"),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _publish(context),
                      child: const Text("Publish"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}