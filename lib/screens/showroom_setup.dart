import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'digital_personal_dashboard.dart';
import 'upload_page.dart';
import '../services/firestore_service.dart';
import '../models/showroom_registration.dart';

class ShowroomSetup extends StatefulWidget {
  const ShowroomSetup({super.key});
  @override
  State<ShowroomSetup> createState() => _ShowroomSetupState();
}

class _ShowroomSetupState extends State<ShowroomSetup> {
  // Theme Colors
  final Color primaryEarth = const Color(0xFFE27D5F);
  final Color goldAccent = const Color(0xFFD4A574);
  final Color clayBg = const Color(0xFFF5F2E9);
  final Color deepHeritage = const Color(0xFF4A7043);

  XFile? _profileImage;
  String _artistName = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  String _businessName = '';
  String _businessEmail = '';
  String _businessPhone = '';
  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isGeneratingStory = false;
  bool _isSaving = false;
  
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _backendUrl = 'https://c8c456f1b408.ngrok-free.app';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async => await _speech.initialize();

  Future<void> _pickProfileImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _profileImage = picked);
  }

  void _handleVoiceInput() {
    if (_isListening) _stopListening(); else _startListening();
  }

  void _startListening() async {
    if (await Permission.microphone.request().isGranted) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() => _storyController.text = result.recognizedWords);
        if (result.finalResult) _stopListening();
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    if (_storyController.text.isNotEmpty) _generateStory(_storyController.text);
  }

  Future<void> _generateStory(String prompt) async {
    setState(() => _isGeneratingStory = true);
    try {
      final response = await http.post(Uri.parse('$_backendUrl/generate-story'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'prompt': prompt})).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        setState(() => _storyController.text = json.decode(response.body)['story']);
      }
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() => _isGeneratingStory = false);
    }
  }

  Future<void> _saveShowroomData() async {
    if (_nameController.text.isEmpty || _storyController.text.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      String? url;
      if (_profileImage != null) {
        final ref = _storage.ref().child('profiles/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(File(_profileImage!.path));
        url = await ref.getDownloadURL();
      }
      await _firestoreService.addShowroom(ShowroomRegistration(
        artistName: _nameController.text,
        artistStory: _storyController.text,
        businessName: _businessName,
        businessEmail: _businessEmail,
        businessPhone: _businessPhone,
        profileImageUrl: url,
        createdAt: DateTime.now(),
      ).toMap());
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clayBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: const BackButton(color: Color(0xFF4A7043)),
        title: Text('Artisan Setup', style: TextStyle(color: deepHeritage, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Profile & Name Section
            Row(
              children: [
                GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 40, 
                    backgroundColor: goldAccent.withOpacity(0.2),
                    backgroundImage: _profileImage != null ? FileImage(File(_profileImage!.path)) : null,
                    child: _profileImage == null ? Icon(Icons.add_a_photo, color: goldAccent) : null,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Artisan Name", 
                      filled: true, 
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) => setState(() => _artistName = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Story Section
            Align(alignment: Alignment.centerLeft, child: Text("Your Story", style: TextStyle(color: deepHeritage, fontWeight: FontWeight.bold))),
            const SizedBox(height: 6),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                TextField(
                  controller: _storyController, 
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Voice record your journey...", 
                    filled: true, 
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton.small(
                    onPressed: _isGeneratingStory ? null : _handleVoiceInput,
                    backgroundColor: _isListening ? Colors.red : primaryEarth,
                    elevation: 2,
                    child: _isGeneratingStory 
                      ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                      : Icon(_isListening ? Icons.stop : Icons.mic, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Business Details
            Align(alignment: Alignment.centerLeft, child: Text("Business Info", style: TextStyle(color: deepHeritage, fontWeight: FontWeight.bold))),
            const SizedBox(height: 6),
            _buildBusinessField("Business Name", (val) => _businessName = val),
            const SizedBox(height: 8),
            _buildBusinessField("Email", (val) => _businessEmail = val, type: TextInputType.emailAddress),
            const SizedBox(height: 8),
            _buildBusinessField("Phone", (val) => _businessPhone = val, type: TextInputType.phone),
            const SizedBox(height: 20),
            // Actions
            Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    text: "Done", 
                    color: deepHeritage, 
                    icon: Icons.check, 
                    onPressed: _isSaving ? null : () async {
                      await _saveShowroomData();
                      if (mounted) {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (c) => DigitalPersonalDashboard(
                              profileName: _artistName, 
                              profileImagePath: _profileImage?.path, 
                              profileEmail: _businessEmail, 
                              artistStory: _storyController.text, 
                              businessName: _businessName, 
                              businessPhone: _businessPhone
                            )
                          )
                        );
                      }
                    }
                  )
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionBtn(
                    text: "Add Art", 
                    color: primaryEarth, 
                    icon: Icons.upload, 
                    onPressed: _isSaving ? null : () async {
                      await _saveShowroomData();
                      if (mounted) {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (c) => UploadPage(
                              artisanName: _artistName, 
                              artisanCategory: 'Artisan', 
                              location: 'India'
                            )
                          )
                        );
                      }
                    }
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessField(String hint, Function(String) onChanged, {TextInputType type = TextInputType.text}) {
    return TextField(
      keyboardType: type, 
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint, 
        filled: true, 
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String text; 
  final Color color; 
  final IconData icon; 
  final VoidCallback? onPressed;
  
  const _ActionBtn({required this.text, required this.color, required this.icon, required this.onPressed});
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed, 
      icon: Icon(icon, size: 18), 
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color, 
        foregroundColor: Colors.white, 
        padding: const EdgeInsets.symmetric(vertical: 14), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
      ),
    );
  }
}