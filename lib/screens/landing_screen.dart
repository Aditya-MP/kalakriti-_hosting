import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'showroom_setup.dart';
import 'latest_artwork.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consistent artisan theme from login
    final Color primaryEarth = const Color(0xFFE27D5F);
    final Color goldAccent = const Color(0xFFD4A574);
    final Color clayBg = const Color(0xFFF5F2E9);
    final Color deepHeritage = const Color(0xFF4A7043);
    final Color warmShadow = const Color(0xFFFFB997);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              clayBg,
              clayBg.withOpacity(0.9),
              const Color(0xFFFDE8D7),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero title with artisan spacing
                Container(
                  margin: const EdgeInsets.only(bottom: 48),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: primaryEarth.withOpacity(0.15),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.handshake_outlined,
                        size: 64,
                        color: goldAccent,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Choose Your Path",
                        style: TextStyle(
                          color: Color(0xFF161411),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Join as artisan or admirer",
                        style: TextStyle(
                          color: deepHeritage.withOpacity(0.8),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Kalakaar (Artisan) Card - Enhanced
                _PathCard(
                  imageUrl: "https://picsum.photos/400/300?random=1",
                  title: "I am a Kalakaar",
                  subtitle: "Artisan - Innovator - Maker",
                  buttonText: "Start Crafting",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ShowroomSetup(),
                      ),
                    );
                  },
                  color: primaryEarth,
                ),
                const SizedBox(height: 32),
                // Rasik (Admirer) Card
                _PathCard(
                  imageUrl: "https://picsum.photos/400/300?random=2",
                  title: "I am a Rasik",
                  subtitle: "Connoisseur - Admirer - Supporter",
                  buttonText: "Start Discovering",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LatestArtwork(),
                      ),
                    );
                  },
                  color: deepHeritage,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable artisan path card with perfect padding
class _PathCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onTap;
  final Color color;

  const _PathCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero image with overlay
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        color.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF161411),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF897060),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

