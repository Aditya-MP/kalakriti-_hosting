import 'dart:io';
import 'package:flutter/material.dart';
import 'upload_page.dart'; // Make sure the path is correct

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
    final List<String> productImages = [
      "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/11tty4cl_expires_30_days.png",
      "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/au41h294_expires_30_days.png",
      "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/pnjur7bk_expires_30_days.png",
      "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/i7z03v72_expires_30_days.png",
      "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/tarlq8pp_expires_30_days.png",
      "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/1io91f4o_expires_30_days.png",
    ];

    final List<String> productTitles = [
      "Handcrafted Ceramic Vase",
      "Embroidered Silk Scarf",
      "Wooden Carved Elephant",
      "Abstract Painting on Canvas",
      "Terracotta Jewelry Set",
      "Woven Cotton Rug"
    ];

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(profileName),
              accountEmail: Text(profileEmail),
              currentAccountPicture: profileImagePath != null && profileImagePath!.isNotEmpty
                  ? CircleAvatar(backgroundImage: FileImage(File(profileImagePath!)))
                  : const CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/bwaij4n0_expires_30_days.png'),
              ),
              decoration: const BoxDecoration(color: Colors.blueAccent),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Profile Info'),
                    content: Text(
                      'Name: $profileName\nEmail: $profileEmail\nBusiness: $businessName\nPhone: $businessPhone\nArtist Story:\n$artistStory',
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Settings'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SwitchListTile(
                          title: const Text('Enable Notifications'),
                          value: true,
                          onChanged: (val) {},
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('My Studio Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text('Overview',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard(context, "\$1,234", "Total Revenue", Colors.deepPurpleAccent),
                _buildStatCard(context, "25", "Products Listed", Colors.blueAccent),
                _buildStatCard(context, "150", "Profile Views", Colors.orangeAccent),
                _buildStatCard(context, "5", "Sales This Month", Colors.green),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UploadPage(
                        artisanName: profileName,
                        artisanCategory: 'Artisan',
                        location: 'India',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Add New Product"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Your Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: productImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withAlpha(38),
                        blurRadius: 6,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                        child: Image.network(
                          productImages[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        productTitles[index],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, Color color) {
    final cardWidth = (MediaQuery.of(context).size.width - (16 * 3)) / 2;
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
