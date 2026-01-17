import 'dart:io';
import 'package:flutter/material.dart';
import 'upload_page.dart';

class DigitalPersonalDashboard extends StatelessWidget {
  final String profileName;
  final String? profileImagePath;
  final String profileEmail;
  final String artistStory;
  final String businessName;
  final String businessPhone;

  const DigitalPersonalDashboard({
    super.key,
    required this.profileName,
    this.profileImagePath,
    required this.profileEmail,
    required this.artistStory,
    required this.businessName,
    required this.businessPhone,
  });

  @override
  Widget build(BuildContext context) {
    // Consistent artisan theme from previous screens
    final Color primaryEarth = const Color(0xFFE27D5F);
    final Color goldAccent = const Color(0xFFD4A574);
    final Color clayBg = const Color(0xFFF5F2E9);
    final Color deepHeritage = const Color(0xFF4A7043);
    final Color warmShadow = const Color(0xFFFFB997);

    final List<Map<String, dynamic>> artworks = [
      {'title': 'Clay Pottery Vase', 'price': '₹1,250', 'img': 'https://picsum.photos/400/300?random=3'},
      {'title': 'Block Printed Dupatta', 'price': '₹850', 'img': 'https://picsum.photos/400/300?random=4'},
      {'title': 'Wooden Carved Box', 'price': '₹2,100', 'img': 'https://picsum.photos/400/300?random=5'},
      {'title': 'Madhubani Painting', 'price': '₹3,500', 'img': 'https://picsum.photos/400/300?random=6'},
      {'title': 'Terracotta Earrings', 'price': '₹650', 'img': 'https://picsum.photos/400/300?random=7'},
      {'title': 'Handloom Basket', 'price': '₹950', 'img': 'https://picsum.photos/400/300?random=8'},
    ];

    return Scaffold(
      backgroundColor: clayBg,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(children: [
          UserAccountsDrawerHeader(
            accountName: Text(profileName, style: TextStyle(fontWeight: FontWeight.bold, color: deepHeritage)),
            accountEmail: Text(profileEmail),
            currentAccountPicture: CircleAvatar(
              backgroundImage: profileImagePath != null 
                ? FileImage(File(profileImagePath!)) as ImageProvider
                : const NetworkImage('https://picsum.photos/150/150?random=9'),
            ),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryEarth, goldAccent])),
          ),
          ListTile(leading: Icon(Icons.dashboard, color: primaryEarth), title: const Text('Studio'), onTap: () => Navigator.pop(context)),
          ListTile(leading: Icon(Icons.brush, color: primaryEarth), title: const Text('My Artworks'), onTap: () => Navigator.pop(context)),
          ListTile(leading: Icon(Icons.people_outline, color: primaryEarth), title: const Text('Patrons'), onTap: () {}),
          ListTile(leading: Icon(Icons.palette_outlined, color: primaryEarth), title: const Text('Story'), onTap: () => _showStory(context)),
          ListTile(leading: Icon(Icons.settings, color: primaryEarth), title: const Text('Settings'), onTap: () => _showSettings(context)),
        ]),
      ),
      appBar: AppBar(
        title: const Text('My Artisan Studio', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: deepHeritage,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: primaryEarth.withOpacity(0.3), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card - Consistent with showroom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: primaryEarth.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
                border: Border.all(color: goldAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: profileImagePath != null 
                            ? FileImage(File(profileImagePath!)) as ImageProvider
                            : const NetworkImage('https://picsum.photos/150/150?random=9'), 
                          fit: BoxFit.cover
                        )
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profileName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: deepHeritage)),
                        Text(businessName.isEmpty ? 'Solo Artisan' : businessName, style: TextStyle(fontSize: 14, color: primaryEarth)),
                        const SizedBox(height: 4),
                        Row(children: [Icon(Icons.star_rate, color: goldAccent, size: 16), const SizedBox(width: 4), const Text('Verified Artisan', style: TextStyle(fontWeight: FontWeight.w600))]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Stats Grid - Matches landing rhythm
            Text('Studio Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: deepHeritage)),
            const SizedBox(height: 12),
            Wrap(runSpacing: 12, spacing: 12, children: [
              _ArtisanStat('₹2,450', 'Monthly Earnings', primaryEarth),
              _ArtisanStat('28', 'Live Artworks', goldAccent),
              _ArtisanStat('420', 'Total Views', deepHeritage),
              _ArtisanStat('8', 'Pending Orders', primaryEarth),
            ]),
            const SizedBox(height: 20),
            // Add New Artwork Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UploadPage(artisanName: profileName, artisanCategory: 'Artisan', location: 'India'))),
                icon: const Icon(Icons.add_box_outlined),
                label: const Text('Create New Artwork'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryEarth,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Artworks Gallery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: deepHeritage)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: artworks.length,
              itemBuilder: (context, i) => _ArtworkCard(artwork: artworks[i]),
            ),
          ],
        ),
      ),
    );
  }

  void _showStory(BuildContext context) => showDialog(context: context, builder: (c) => AlertDialog(
    title: const Text('Artisan Story'),
    content: SingleChildScrollView(child: Text(artistStory)),
    actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))],
  ));

  void _showSettings(BuildContext context) => showDialog(context: context, builder: (c) => AlertDialog(
    title: const Text('Studio Settings'),
    content: const SwitchListTile(title: Text('Order Notifications'), value: true, onChanged: null),
    actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Done'))],
  ));
}

class _ArtisanStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _ArtisanStat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      width: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF4A7043)), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ArtworkCard extends StatelessWidget {
  final Map<String, dynamic> artwork;
  const _ArtworkCard({required this.artwork});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), 
            child: Image.network(artwork['img'], height: 110, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(artwork['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(artwork['price'], style: const TextStyle(color: Color(0xFFE27D5F), fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}