import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
<<<<<<< HEAD
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'digital_personal_dashboard.dart';
import 'upload_page.dart';
import '../services/firestore_service.dart';
import '../models/showroom_registration.dart';
=======
import 'digital_personal_dashboard.dart';
import 'upload_page.dart';
>>>>>>> 7a6d40a (Initial project push)

class ShowroomSetup extends StatefulWidget {
  const ShowroomSetup({super.key});

  @override
  State<ShowroomSetup> createState() => _ShowroomSetupState();
}

class _ShowroomSetupState extends State<ShowroomSetup> {
  XFile? _profileImage;
  String _artistName = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  String _businessName = '';
  String _businessEmail = '';
  String _businessPhone = '';
  final ImagePicker _picker = ImagePicker();

<<<<<<< HEAD
  // Firebase services
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorage _storage = FirebaseStorage.instance;

=======
>>>>>>> 7a6d40a (Initial project push)
  // Speech to text variables
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isGeneratingStory = false;
<<<<<<< HEAD
  bool _isSaving = false;

// Backend API URL - UPDATED WITH CURRENT NGROK URL
static const String _backendUrl = 'https://c8c456f1b408.ngrok-free.app';
=======
>>>>>>> 7a6d40a (Initial project push)

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize();

    if (!available && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
      });
    }
  }

<<<<<<< HEAD
  Future<bool> _checkBackendConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Backend connection check failed: $e');
      return false;
    }
  }

=======
>>>>>>> 7a6d40a (Initial project push)
  Future<void> _pickProfileImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedImage != null) {
      setState(() {
        _profileImage = pickedImage;
      });
    }
  }

  void _handleVoiceInput() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() async {
    // Request microphone permission
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required')),
          );
        });
      }
      return;
    }

    setState(() => _isListening = true);

    _speech.listen(
      onResult: (result) {
        setState(() {
          // Update the story controller with recognized text
          if (result.recognizedWords.isNotEmpty) {
            _storyController.text = result.recognizedWords;
          }
        });

        if (result.finalResult) {
          _stopListening();
        }
      },
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);

    // Generate a story from the recognized text
    if (_storyController.text.isNotEmpty) {
      _generateStory(_storyController.text);
    }
  }

  // Generate story using Gemma model API
  Future<void> _generateStory(String prompt) async {
    setState(() => _isGeneratingStory = true);

<<<<<<< HEAD
    // First check if backend is reachable
    final bool isBackendReachable = await _checkBackendConnection();
    
    if (!isBackendReachable) {
      if (mounted) {
        setState(() => _isGeneratingStory = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot connect to AI service. Using fallback story.'),
            duration: Duration(seconds: 3),
          ),
        );
        
        // Use fallback
        String story = _createStoryFromPrompt(prompt);
        _storyController.text = story;
      }
      return;
    }

    try {
      print('Sending request to: $_backendUrl/generate-story');
      print('Prompt: $prompt');
      
      final response = await http.post(
        Uri.parse('$_backendUrl/generate-story'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'prompt': prompt}),
      ).timeout(const Duration(seconds: 60));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
=======
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/generate-story'), // For Android emulator
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'prompt': prompt}),
      );
>>>>>>> 7a6d40a (Initial project push)

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String story = data['story'];

        if (mounted) {
          setState(() {
            _storyController.text = story;
            _isGeneratingStory = false;
          });
        }
      } else {
<<<<<<< HEAD
        throw Exception('Failed to generate story: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error details: $e');
      
=======
        throw Exception('Failed to generate story: ${response.statusCode}');
      }
    } catch (e) {
>>>>>>> 7a6d40a (Initial project push)
      if (mounted) {
        setState(() => _isGeneratingStory = false);
      }

<<<<<<< HEAD
      // Show error message but still use fallback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI service unavailable: $e. Using fallback story.'),
          duration: const Duration(seconds: 3),
        ),
      );
=======
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error generating story: $e')),
          );
        });
      }
>>>>>>> 7a6d40a (Initial project push)

      // Fallback to local generation if API fails
      String story = _createStoryFromPrompt(prompt);
      if (mounted) {
        setState(() {
          _storyController.text = story;
        });
      }
    }
  }

  // Fallback story generation if API is not available
  String _createStoryFromPrompt(String prompt) {
    if (prompt.toLowerCase().contains('pottery') ||
        prompt.toLowerCase().contains('ceramic') ||
        prompt.toLowerCase().contains('clay')) {
      return """
In the heart of Jaipur, a master ceramicist spent decades perfecting the art of pottery. 
Each piece was shaped with hands that understood the soul of clay, telling stories of tradition 
and innovation. The artisan's studio was filled with creations that blended ancient techniques 
with contemporary designs, each piece a testament to a lifelong journey with earth and fire.

The ceramicist's work gained recognition for its unique blend of traditional Rajasthani motifs 
and modern aesthetics. From delicate teacups to majestic vases, each piece carried the essence 
of Jaipur's rich cultural heritage while speaking to contemporary sensibilities.

This artistic journey wasn't just about creating objects; it was about preserving a legacy 
while pushing the boundaries of what clay could become under guided, passionate hands.
""";
    } else if (prompt.toLowerCase().contains('textile') ||
        prompt.toLowerCase().contains('fabric') ||
        prompt.toLowerCase().contains('weave')) {
      return """
A textile artist in Jaipur dedicated a lifetime to the loom, weaving stories in vibrant threads. 
The clack-clack of the wooden machine was the rhythm of creation, each pass of the shuttle 
adding another line to narratives told in silk and cotton.

Specializing in traditional block printing and contemporary designs, the artisan's work 
became known for its bold colors and intricate patterns. Each textile piece captured 
the spirit of Rajasthan - the golden deserts, the royal palaces, the vibrant festivals.

The workshop became a sanctuary where apprentices learned not just techniques, but the 
philosophy of creating beauty that lasts generations. The textiles traveled across oceans, 
carrying with them stories of Jaipur's artistic soul.
""";
    } else if (prompt.toLowerCase().contains('paint') ||
        prompt.toLowerCase().contains('art')) {
      return """
A visionary painter from Jaipur transformed blank canvases into windows to other worlds. 
With brushes dipped in dreams and colors mixed with emotion, each stroke told a part of 
a story that words could never fully capture.

The artist's style evolved from traditional miniature paintings to bold contemporary works, 
always maintaining a connection to Rajasthani cultural roots. Exhibitions in galleries 
from Delhi to Paris showcased works that explored the tension between tradition and modernity.

The studio walls, splattered with years of creative energy, witnessed the birth of 
masterpieces that would eventually find homes in collections around the world, each 
painting carrying a piece of Jaipur's luminous spirit.
""";
    } else {
      // Generic artisan story
      return """
An artisan from the vibrant city of Jaipur embarked on a creative journey that would 
define a lifetime. With hands skilled through years of dedicated practice and a heart 
full of passion, the artist developed a unique style that honored tradition while 
embracing innovation.

The workshop became a space where materials transformed into meaningful creations, 
each piece telling its own story. Clients and collectors appreciated not just the 
finished works, but the narrative behind each creation - the inspiration, the process, 
the challenges overcome.

This artistic path wasn't always easy, but the satisfaction of creating beauty and 
preserving cultural heritage made every challenge worthwhile. The artisan's creations 
now serve as testaments to a life dedicated to craft, each piece carrying forward 
traditions while speaking to contemporary sensibilities.
""";
    }
  }

<<<<<<< HEAD
  // Upload image to Firebase Storage and return the download URL
  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child('profile_images/$fileName');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Save showroom data to Firestore
  Future<void> _saveShowroomData() async {
    if (_nameController.text.isEmpty || _storyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? profileImageUrl;

      // Upload profile image if selected
      if (_profileImage != null) {
        profileImageUrl = await _uploadImage(File(_profileImage!.path));
      }

      // Create showroom data
      ShowroomRegistration showroom = ShowroomRegistration(
        artistName: _nameController.text,
        artistStory: _storyController.text,
        businessName: _businessName,
        businessEmail: _businessEmail,
        businessPhone: _businessPhone,
        profileImageUrl: profileImageUrl,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestoreService.addShowroom(showroom.toMap());
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Showroom data saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

=======
>>>>>>> 7a6d40a (Initial project push)
  @override
  Widget build(BuildContext context) {
    final labelStyle =
    const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0C0F1C));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Showroom Setup',
          style: TextStyle(
              color: Color(0xFF0C0F1C), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
<<<<<<< HEAD
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: const Color(0xFFE5E8F4),
                        backgroundImage: _profileImage != null
                            ? FileImage(File(_profileImage!.path))
                            : const NetworkImage(
                          'https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/bwaij4n0_expires_30_days.png',
                        ) as ImageProvider,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ],
=======
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickProfileImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: const Color(0xFFE5E8F4),
                    backgroundImage: _profileImage != null
                        ? FileImage(File(_profileImage!.path))
                        : const NetworkImage(
                      'https://storage.googleapis.com/tagjs-prod.appspot.com/v1/BSML5JvnyV/bwaij4n0_expires_30_days.png',
                    ) as ImageProvider,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "Enter your name",
                  filled: true,
                  fillColor: Color(0xFFE5E8F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
>>>>>>> 7a6d40a (Initial project push)
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: "Enter your name",
                      filled: true,
                      fillColor: Color(0xFFE5E8F4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0C0F1C)),
                    onChanged: (val) => setState(() => _artistName = val),
                  ),
<<<<<<< HEAD
                ),
                if (_artistName.isNotEmpty)
                  Text(
                    '@${_artistName.trim().toLowerCase().replaceAll(' ', '')}',
                    style: const TextStyle(color: Color(0xFF47569E), fontSize: 16),
=======
                  Positioned(
                    bottom: 14,
                    right: 14,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isGeneratingStory ? null : _handleVoiceInput,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isListening
                                ? Colors.red
                                : _isGeneratingStory
                                ? Colors.grey
                                : Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: _isGeneratingStory
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : Icon(
                            _isListening ? Icons.mic_off : Icons.mic,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
>>>>>>> 7a6d40a (Initial project push)
                  ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Artist's Story", style: labelStyle),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _storyController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: "Tell us about your artistic journey",
                          filled: true,
                          fillColor: Color(0xFFE5E8F4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        right: 14,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isGeneratingStory ? null : _handleVoiceInput,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _isListening
                                    ? Colors.red
                                    : _isGeneratingStory
                                    ? Colors.grey
                                    : Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: _isGeneratingStory
                                  ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : Icon(
                                _isListening ? Icons.mic_off : Icons.mic,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Business Details (Optional)", style: labelStyle),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      _buildBusinessField("Business Name", _businessName, (val) => setState(() => _businessName = val)),
                      const SizedBox(height: 12),
                      _buildBusinessField("Business Email", _businessEmail, (val) => setState(() => _businessEmail = val), keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _buildBusinessField("Business Phone", _businessPhone, (val) => setState(() => _businessPhone = val), keyboardType: TextInputType.phone),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : () async {
                            await _saveShowroomData();
                            if (mounted && !_isSaving) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DigitalPersonalDashboard(
                                      profileName: _artistName,
                                      profileImagePath: _profileImage?.path,
                                      profileEmail: _businessEmail,
                                      artistStory: _storyController.text,
                                      businessName: _businessName,
                                      businessPhone: _businessPhone,
                                    )));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  "Done",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : () async {
                            await _saveShowroomData();
                            if (mounted && !_isSaving) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UploadPage(
                                    artisanName: _artistName,
                                    artisanCategory: 'Artisan',
                                    location: 'India',
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  "Upload Your Art",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _storyController.dispose();
    _speech.stop();
    super.dispose();
  }

  Widget _buildBusinessField(String hint, String value, Function(String) onChanged, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFE5E8F4),
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16)
      ),
      onChanged: onChanged,
    );
  }
}