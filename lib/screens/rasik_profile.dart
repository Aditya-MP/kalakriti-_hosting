import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'latest_artwork.dart';
import 'SearchPage.dart';

class RasikProfile extends StatefulWidget {
  const RasikProfile({super.key});

  @override
  RasikProfileState createState() => RasikProfileState();
}

class RasikProfileState extends State<RasikProfile> {
  File? _profileImage;
  String _name = "Loading...";
  String _bio = "";
  String _about = "";
  String _profileImageUrl = "";

  final List<Map<String, String>> _favorites = [
    {
      "title": "Vibrant Landscapes",
      "artist": "Anika Verma",
      "image": "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/uhjLWlJxTl/b5j8w8cl_expires_30_days.png"
    },
    {
      "title": "Modern Sculptures",
      "artist": "Rohan Kapoor",
      "image": "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/uhjLWlJxTl/0v9m425q_expires_30_days.png"
    },
    {
      "title": "Handcrafted Pottery",
      "artist": "Meera Patel",
      "image": "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/uhjLWlJxTl/zmrgubhe_expires_30_days.png"
    },
  ];

  late final String _uid;
  late final Stream<DocumentSnapshot> _userDocStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _uid = user.uid;
  _userDocStream = firestoreInstance.collection('users').doc(_uid).snapshots();
      _userDocStream.listen((snapshot) {
        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          setState(() {
            _name = data['name'] ?? 'No Name';
            _bio = data['bio'] ?? '';
            _about = data['bio'] ?? '';
            _profileImageUrl = data['profileImageUrl'] ?? '';
          });
        }
      });
    } else {
      _uid = '';
      _name = 'No User';
      _bio = '';
      _about = '';
      _profileImageUrl = '';
    }
  }

  Future _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future _editProfile() async {
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(name: _name, bio: _bio, profileImageUrl: _profileImageUrl, uid: _uid),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _name = result['name'] ?? _name;
        _bio = result['bio'] ?? _bio;
        _profileImageUrl = result['profileImageUrl'] ?? _profileImageUrl;
        if (result['profileImage'] != null) {
          _profileImage = result['profileImage'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          color: const Color(0xFFFFFFFF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: const Color(0xFFFFFFFF),
                  width: double.infinity,
                  height: double.infinity,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IntrinsicHeight(
                          child: SizedBox(
                            width: double.infinity,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IntrinsicHeight(
                                      child: Container(
                                        color: const Color(0xFFFFFFFF),
                                        width: double.infinity,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            IntrinsicHeight(
                                              child: Container(
                                                color: const Color(0xFFFFFFFF),
                                                padding: const EdgeInsets.only(top: 16, bottom: 16, left: 64, right: 16),
                                                width: double.infinity,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: SizedBox(
                                                        width: double.infinity,
                                                        child: Text(
                                                          "Profile",
                                                          style: TextStyle(
                                                            color: const Color(0xFF161411),
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFF5F5F5),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: IconButton(
                                                        icon: Icon(
                                                          Icons.settings,
                                                          size: 24,
                                                          color: const Color(0xFF161411),
                                                        ),
                                                        onPressed: () {
                                                          print("Settings button pressed");
                                                        },
                                                        padding: EdgeInsets.zero,
                                                        splashRadius: 20,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            IntrinsicHeight(
                                              child: Container(
                                                padding: const EdgeInsets.all(16),
                                                width: double.infinity,
                                                child: Column(
                                                  children: [
                                                    IntrinsicWidth(
                                                      child: IntrinsicHeight(
                                                        child: Column(
                                                          children: [
                                                            Center(
                                                              child: Stack(
                                                                children: [
                                                                  Container(
                                                                    margin: const EdgeInsets.only(bottom: 16),
                                                                    width: 128,
                                                                    height: 128,
                                                                    decoration: BoxDecoration(
                                                                      shape: BoxShape.circle,
                                                                      color: Colors.orange.shade100,
                                                                      image: _profileImage != null
                                                                          ? DecorationImage(
                                                                              image: FileImage(_profileImage!),
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : _profileImageUrl.isNotEmpty
                                                                              ? DecorationImage(
                                                                                  image: NetworkImage(_profileImageUrl),
                                                                                  fit: BoxFit.cover,
                                                                                )
                                                                              : const DecorationImage(
                                                                                  image: NetworkImage(
                                                                                      "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/uhjLWlJxTl/u2bmmm7s_expires_30_days.png"),
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    bottom: 0,
                                                                    right: 0,
                                                                    child: InkWell(
                                                                      onTap: _pickImage,
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.orange,
                                                                          shape: BoxShape.circle,
                                                                          border: Border.all(width: 3, color: Colors.white),
                                                                        ),
                                                                        padding: const EdgeInsets.all(6),
                                                                        child: const Icon(
                                                                          Icons.camera_alt_rounded,
                                                                          color: Colors.white,
                                                                          size: 20,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            IntrinsicWidth(
                                                              child: IntrinsicHeight(
                                                                child: Column(
                                                                  children: [
                                                                    IntrinsicWidth(
                                                                      child: IntrinsicHeight(
                                                                        child: Container(
                                                                          padding: const EdgeInsets.only(bottom: 1),
                                                                          child: Column(
                                                                            children: [
                                                                              Text(
                                                                                _name,
                                                                                style: TextStyle(
                                                                                  color: const Color(0xFF161411),
                                                                                  fontSize: 22,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    IntrinsicWidth(
                                                                      child: IntrinsicHeight(
                                                                        child: Container(
                                                                          padding: const EdgeInsets.only(bottom: 1),
                                                                          child: Column(
                                                                            children: [
                                                                              Text(
                                                                                _bio.isNotEmpty ? _bio : "Art Enthusiast",
                                                                                style: TextStyle(
                                                                                  color: const Color(0xFF897060),
                                                                                  fontSize: 16,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    IntrinsicWidth(
                                                                      child: IntrinsicHeight(
                                                                        child: Container(
                                                                          padding: const EdgeInsets.only(bottom: 1),
                                                                          child: Column(
                                                                            children: [
                                                                              Text(
                                                                                "Joined 2021",
                                                                                style: TextStyle(
                                                                                  color: const Color(0xFF897060),
                                                                                  fontSize: 16,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(height: 12),
                                                                    ElevatedButton(
                                                                      onPressed: _editProfile,
                                                                      style: ElevatedButton.styleFrom(
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(8),
                                                                        ),
                                                                      ),
                                                                      child: const Text("Edit Profile"),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
                          child: Text(
                            "About",
                            style: TextStyle(
                              color: const Color(0xFF161411),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          width: double.infinity,
                          child: Text(
                            _about,
                            style: TextStyle(
                              color: const Color(0xFF161411),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 16, bottom: 16, left: 16),
                          child: Text(
                            "Favorites",
                            style: TextStyle(
                              color: const Color(0xFF161411),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 195,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                            itemCount: _favorites.length,
                            itemBuilder: (_, index) {
                              final fav = _favorites[index];
                              return Container(
                                width: 160,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      width: 160,
                                      height: 135,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          fav["image"]!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      fav["title"]!,
                                      style: TextStyle(
                                        color: const Color(0xFF161411),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "By ${fav["artist"]!}",
                                      style: TextStyle(
                                        color: const Color(0xFF897060),
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            currentIndex: 2,
            onTap: (index) {
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LatestArtwork()),
                );
              } else if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              } else {
                // Stay on the current page
              }
            },
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black54,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 28),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search, size: 28),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 28),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------- Edit Profile Page --------------------

class EditProfilePage extends StatefulWidget {
  final String name;
  final String bio;
  final String profileImageUrl;
  final String uid;

  const EditProfilePage({
    super.key,
    required this.name,
    required this.bio,
    required this.profileImageUrl,
    required this.uid,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  File? _newProfileImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
    _bioCtrl = TextEditingController(text: widget.bio);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickNewImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (widget.uid.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user ID found. Please log in to update profile.')),
        );
      }
      return;
    }
    setState(() {
      _isSaving = true;
    });
    try {
      String? imageUrl = widget.profileImageUrl;
      if (_newProfileImage != null) {
        final ref = FirebaseStorage.instance.ref().child('profile_images/${widget.uid}.jpg');
        await ref.putFile(_newProfileImage!);
        imageUrl = await ref.getDownloadURL();
      }
      final updateData = {
        'name': _nameCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'profileImageUrl': imageUrl,
      };
  await firestoreInstance
          .collection('users')
          .doc(widget.uid)
          .set(updateData, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context, updateData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 64,
                  backgroundColor: Colors.orange.shade100,
                  backgroundImage: _newProfileImage != null
                      ? FileImage(_newProfileImage!)
                      : widget.profileImageUrl.isNotEmpty
                          ? NetworkImage(widget.profileImageUrl) as ImageProvider
                          : const NetworkImage(
                              "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/uhjLWlJxTl/u2bmmm7s_expires_30_days.png",
                            ),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: InkWell(
                    onTap: _pickNewImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(width: 3, color: Colors.white),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bioCtrl,
              decoration: const InputDecoration(labelText: "Bio / About"),
              minLines: 2,
              maxLines: 4,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}