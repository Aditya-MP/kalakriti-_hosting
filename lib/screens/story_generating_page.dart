import 'package:flutter/material.dart';

class StoryGeneratingPage extends StatefulWidget {
  const StoryGeneratingPage({super.key});

  @override
  State<StoryGeneratingPage> createState() => _StoryGeneratingPageState();
}

class _StoryGeneratingPageState extends State<StoryGeneratingPage> {
  bool isRecording = false;

  void _toggleRecording() {
    setState(() {
      isRecording = !isRecording;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Container(
            color: const Color(0xFFFFFFFF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Top Section ----
                Container(
                  color: const Color(0xFFF7F9FC),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        width: double.infinity,
                        child: const Text(
                          "Listening...",
                          style: TextStyle(
                            color: Color(0xFF0C141C),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        height: 220,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                            // Use your actual asset or image link here:
                            "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/9BCNdnhUVz/1abfdkv5_expires_30_days.png",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFE8EDF4),
                              child: const Center(child: Icon(Icons.mic_rounded, size: 72, color: Color(0xFFB0B6BE))),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: _toggleRecording,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFE8EDF4),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 36),
                              child: Text(
                                isRecording ? "Stop Recording" : "Start Recording",
                                style: const TextStyle(
                                  color: Color(0xFF0C141C),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // ---- Buttons Section ----
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          // Your send logic here
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFF3D99F4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          width: double.infinity,
                          child: const Center(
                            child: Text(
                              "Send",
                              style: TextStyle(
                                color: Color(0xFFF7F9FC),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFE8EDF4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          width: double.infinity,
                          child: const Center(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Color(0xFF0C141C),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
