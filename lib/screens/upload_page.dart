import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pre_post_overview.dart'; 
import 'story_generating_page.dart';

class UploadPage extends StatefulWidget {
  final String? artisanName;
  final String? artisanCategory;
  final String? location;

  const UploadPage({
    super.key,
    this.artisanName,
    this.artisanCategory,
    this.location,
  });

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  // Artisan theme palette
  final Color primaryEarth = const Color(0xFFE27D5F);
  final Color goldAccent = const Color(0xFFD4A574);
  final Color clayBg = const Color(0xFFF5F2E9);
  final Color deepHeritage = const Color(0xFF4A7043);

  File? _image;
  final picker = ImagePicker();
  String productName = '';
  String artworkDesc = '';
  String editableCategory = "";
  final TextEditingController _categoryController = TextEditingController();

  String predictedPriceLow = "₹1000";
  String predictedPriceHigh = "₹2500";
  bool isPredictingPrice = false;

  final List<String> categoryOptions = const [
    'Pottery', 'Ceramics', 'Wood carving', 'Weaving', 'Hand embroidery', 
    'Metalworking', 'Leather crafting', 'Stone carving', 'Glassblowing',
    'Handloom weaving', 'Terracotta art', 'Calligraphy', 'Jewelry making',
    'Bamboo craft', 'Lacquerware', 'Beadwork',
  ];

  String get predictedPrice => predictedPriceHigh;

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _openCategorySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: goldAccent, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text("Select Craft Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: deepHeritage)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: categoryOptions.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(categoryOptions[index]),
                  onTap: () {
                    setState(() {
                      editableCategory = categoryOptions[index];
                      _categoryController.text = categoryOptions[index];
                    });
                    Navigator.pop(context);
                    _predictPrice(categoryOptions[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<void> _predictPrice(String category) async {
    setState(() => isPredictingPrice = true);
    // Hardcoded logic for instant UI update
    final Map<String, String> prices = {
      'pottery': '₹800 - ₹2,500', 'wood carving': '₹2,000 - ₹8,500', 
      'hand embroidery': '₹1,200 - ₹4,000', 'jewelry making': '₹3,000 - ₹15,000'
    };
    await Future.delayed(const Duration(milliseconds: 800));
    final range = prices[category.toLowerCase()] ?? '₹1,500 - ₹5,000';
    setState(() {
      predictedPriceLow = range.split(' - ')[0];
      predictedPriceHigh = range.split(' - ')[1];
      isPredictingPrice = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clayBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.close, color: deepHeritage), onPressed: () => Navigator.pop(context)),
        title: Text("Upload Artwork", style: TextStyle(color: deepHeritage, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker - Artisan Style
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200, 
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: goldAccent.withOpacity(0.3), width: 1.5),
                  image: _image != null ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover) : null,
                  boxShadow: [BoxShadow(color: primaryEarth.withOpacity(0.1), blurRadius: 20)],
                ),
                child: _image == null ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 50, color: goldAccent),
                    const SizedBox(height: 8),
                    Text("Add Masterpiece Photo", style: TextStyle(color: goldAccent, fontWeight: FontWeight.w500)),
                  ],
                ) : null,
              ),
            ),
            const SizedBox(height: 24),
            // Inputs - Consistent with login/showroom
            _ArtisanField(label: "Artwork Name", hint: "e.g., Terracotta Ganesha", onChanged: (v) => productName = v, color: primaryEarth),
            const SizedBox(height: 16),
            _ArtisanField(label: "Artisan Story / Description", hint: "Tell the soul of your creation...", onChanged: (v) => artworkDesc = v, color: deepHeritage, maxLines: 4),
            const SizedBox(height: 16),
            // Voice AI Trigger
            Center(
              child: ActionChip(
                avatar: const Icon(Icons.mic, color: Colors.white, size: 18),
                label: const Text("Voice Story Assistant"),
                backgroundColor: primaryEarth,
                labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoryGeneratingPage())),
              ),
            ),
            const SizedBox(height: 24),
            // Category Selector
            Text("Category", style: TextStyle(fontWeight: FontWeight.bold, color: deepHeritage)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _openCategorySheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(16), 
                  border: Border.all(color: goldAccent.withOpacity(0.3))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      editableCategory.isEmpty ? "Select Category" : editableCategory, 
                      style: TextStyle(color: editableCategory.isEmpty ? Colors.grey : deepHeritage)
                    ),
                    Icon(Icons.keyboard_arrow_down, color: goldAccent),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // AI Price Range Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: goldAccent.withOpacity(0.1), blurRadius: 15)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.insights, color: goldAccent, size: 20), 
                      const SizedBox(width: 8), 
                      const Text("AI Market Value Guide", style: TextStyle(fontWeight: FontWeight.bold))
                    ]
                  ),
                  const SizedBox(height: 12),
                  isPredictingPrice 
                    ? const LinearProgressIndicator() 
                    : Text("$predictedPriceLow - $predictedPriceHigh", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryEarth)),
                  const SizedBox(height: 8),
                  const Text("Based on current Indian handicraft trends", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Final Action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (c) => PrePostOverview(
                      artisanName: widget.artisanName ?? 'Anonymous', 
                      artisanCategory: widget.artisanCategory ?? 'Artisan', 
                      location: widget.location ?? 'India', 
                      productName: productName, 
                      productCategory: editableCategory, 
                      productDescription: artworkDesc, 
                      previewImagePath: _image?.path ?? '', 
                      productPrice: predictedPrice
                    )
                  )
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: deepHeritage, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8, 
                  shadowColor: deepHeritage.withOpacity(0.4),
                ),
                child: const Text("Publish Artwork", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ArtisanField extends StatelessWidget {
  final String label, hint; 
  final Function(String) onChanged; 
  final Color color; 
  final int maxLines;
  
  const _ArtisanField({
    required this.label, 
    required this.hint, 
    required this.onChanged, 
    required this.color, 
    this.maxLines = 1
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines, 
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint, 
            filled: true, 
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ]
    );
  }
}