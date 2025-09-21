import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'pre_post_overview.dart';  // Import the preview screen
import 'story_generating_page.dart'; // Your existing voice recording screen

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
	File? _image;
	final picker = ImagePicker();

	String productName = '';
	String artworkDesc = '';
    String editableCategory = "";
    final TextEditingController _categoryController = TextEditingController();
    
    // Price prediction variables
    String predictedPriceLow = "₹1000";
    String predictedPriceHigh = "₹2500";
    bool isPredictingPrice = false;

	final List<String> categoryOptions = const [
		'Pottery',
		'Ceramics',
		'Wood carving',
		'Weaving',
		'Hand embroidery',
		'Metalworking',
		'Leather crafting',
		'Stone carving',
		'Glassblowing',
		'Handloom weaving',
		'Terracotta art',
		'Calligraphy',
		'Papermaking',
		'Jewelry making',
		'Candle making',
		'Soap making',
		'Macramé',
		'Bamboo craft',
		'Lacquerware',
		'Beadwork',
	];

	// These can be either fixed or dynamically fetched
	String get predictedPrice => predictedPriceHigh; // used for backend/publish
    @override
    void dispose() {
        _categoryController.dispose();
        super.dispose();
    }

    

	void _openCategorySheet() {
		showModalBottomSheet(
			context: context,
			shape: const RoundedRectangleBorder(
				borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
			),
			builder: (ctx) {
				return SafeArea(
					child: ListView.separated(
						padding: const EdgeInsets.all(8),
						itemCount: categoryOptions.length,
						separatorBuilder: (_, __) => const Divider(height: 1),
						itemBuilder: (context, index) {
							final option = categoryOptions[index];
							return ListTile(
								title: Text(option),
								onTap: () {
									setState(() {
										editableCategory = option;
										_categoryController.text = option;
									});
									Navigator.pop(context);
									// Predict price when category is selected
									_predictPrice(option);
								},
							);
						},
					),
				);
			},
		);
	}


	Future<void> _pickImage() async {
		final pickedFile = await picker.pickImage(
			source: ImageSource.gallery,
			imageQuality: 80,
		);
		if (pickedFile != null) {
			setState(() {
				_image = File(pickedFile.path);
			});
		}
	}

	void _onVoiceAssistantTap() {
		Navigator.push(
			context,
			MaterialPageRoute(builder: (_) => const StoryGeneratingPage()),
		);
	}

	Future<void> _predictPrice(String category) async {
		if (category.isEmpty) return;
		
		setState(() {
			isPredictingPrice = true;
		});

		try {
			// First try to get real API response
			final apiPriceRange = await _getRealTimePrice(category);
			
			if (apiPriceRange != null) {
				// Use API response if successful
				final prices = apiPriceRange.split(' - ');
				if (prices.length == 2) {
					setState(() {
						predictedPriceLow = prices[0].trim();
						predictedPriceHigh = prices[1].trim();
					});
					print('API provided price range for $category: $predictedPriceLow - $predictedPriceHigh');
				}
			} else {
				// Fallback to hardcoded price range
				final priceRange = _getCategorySpecificPrompt(category);
				final prices = priceRange.split(' - ');
				
				if (prices.length == 2) {
					setState(() {
						predictedPriceLow = prices[0].trim();
						predictedPriceHigh = prices[1].trim();
					});
					print('Using hardcoded price range for $category: $predictedPriceLow - $predictedPriceHigh');
				}
			}
			
		} catch (e) {
			print('Price prediction failed for $category: $e');
			// Fallback to hardcoded
			final priceRange = _getCategorySpecificPrompt(category);
			final prices = priceRange.split(' - ');
			if (prices.length == 2) {
				setState(() {
					predictedPriceLow = prices[0].trim();
					predictedPriceHigh = prices[1].trim();
				});
			}
		} finally {
			setState(() {
				isPredictingPrice = false;
			});
		}
	}

	Future<String?> _getRealTimePrice(String category) async {
		// Try multiple API endpoints
		final List<String> endpoints = [
			'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=[32mdotenv.env['GEMINI_API_KEY'][0m',
			'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=[32mdotenv.env['GEMINI_API_KEY'][0m',
			'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=[32mdotenv.env['GEMINI_API_KEY'][0m',
		];

		for (String endpoint in endpoints) {
			try {
				print('Trying API endpoint: $endpoint');
				
				final response = await http.post(
					Uri.parse(endpoint),
					headers: {
						'Content-Type': 'application/json',
					},
					body: jsonEncode({
						'contents': [{
							'parts': [{
								'text': 'What is the market price range for handmade $category in India? Respond with exactly: ₹X,XXX - ₹X,XXX. Example: ₹2,500 - ₹8,000'
							}]
						}],
						'generationConfig': {
							'temperature': 0.9,
							'topK': 40,
							'topP': 0.95,
							'maxOutputTokens': 1024,
						}
					}),
				);

				print('API Response Status: ${response.statusCode}');
				print('API Response Body: ${response.body}');

				if (response.statusCode == 200) {
					final data = jsonDecode(response.body);
					if (data['candidates'] != null && data['candidates'].isNotEmpty) {
						final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
						print('SUCCESS: API response for $category: $generatedText');
						
						// Extract price range from response
						final priceRangeRegex = RegExp(r'₹[\d,]+ - ₹[\d,]+');
						final match = priceRangeRegex.firstMatch(generatedText);
						
						if (match != null) {
							print('SUCCESS: Extracted price range: ${match.group(0)}');
							return match.group(0)!;
						}
					}
				} else {
					print('API error with endpoint $endpoint: ${response.statusCode} - ${response.body}');
				}
			} catch (e) {
				print('API call failed with endpoint $endpoint: $e');
			}
		}
		
		print('All API endpoints failed, using fallback');
		return null;
	}

	Future<void> _callGeminiAPI(String category) async {
		try {
			// Try the newer Gemini 1.5 Pro model
			final response = await http.post(
				Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=${dotenv.env['GEMINI_API_KEY']}'),
				headers: {
					'Content-Type': 'application/json',
				},
				body: jsonEncode({
					'contents': [{
						'parts': [{
							'text': 'What is the market price range for handmade $category in India? Respond with exactly: ₹X,XXX - ₹X,XXX'
						}]
					}],
					'generationConfig': {
						'temperature': 0.8,
						'topK': 40,
						'topP': 0.95,
						'maxOutputTokens': 1024,
					}
				}),
			);

			print('API Response Status: ${response.statusCode}');
			print('API Response Body: ${response.body}');

			if (response.statusCode == 200) {
				final data = jsonDecode(response.body);
				if (data['candidates'] != null && data['candidates'].isNotEmpty) {
					final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
					print('Gemini API response for $category: $generatedText');
					
					// Try to extract and use the API response
					final priceRangeRegex = RegExp(r'₹[\d,]+ - ₹[\d,]+');
					final match = priceRangeRegex.firstMatch(generatedText);
					
					if (match != null) {
						final priceRange = match.group(0)!;
						final prices = priceRange.split(' - ');
						if (prices.length == 2) {
							print('API provided price range for $category: $priceRange');
							// You could update the UI here if you want to use API responses
						}
					}
				} else {
					print('No candidates in API response');
				}
			} else {
				print('API error: ${response.statusCode} - ${response.body}');
			}
		} catch (e) {
			print('Background API call failed: $e');
		}
	}

	String _getCategorySpecificPrompt(String category) {
		// Create hardcoded price ranges for each category to ensure variety
		final Map<String, String> categoryPrices = {
			'pottery': '₹800 - ₹2,500',
			'ceramics': '₹1,200 - ₹4,000',
			'wood carving': '₹2,000 - ₹8,000',
			'weaving': '₹1,500 - ₹5,000',
			'hand embroidery': '₹1,000 - ₹3,500',
			'metalworking': '₹2,500 - ₹10,000',
			'leather crafting': '₹1,800 - ₹6,000',
			'stone carving': '₹3,000 - ₹15,000',
			'glassblowing': '₹1,500 - ₹4,500',
			'handloom weaving': '₹2,000 - ₹7,000',
			'terracotta art': '₹600 - ₹2,000',
			'calligraphy': '₹500 - ₹2,000',
			'papermaking': '₹800 - ₹3,000',
			'jewelry making': '₹3,000 - ₹25,000',
			'candle making': '₹300 - ₹1,200',
			'soap making': '₹400 - ₹1,500',
			'macramé': '₹700 - ₹2,800',
			'bamboo craft': '₹900 - ₹3,500',
			'lacquerware': '₹1,500 - ₹5,500',
			'beadwork': '₹600 - ₹2,200',
		};
		
		// Debug: Print the category being requested
		print('DEBUG: Requesting price for category: "$category"');
		print('DEBUG: Category lowercase: "${category.toLowerCase()}"');
		
		// Return the hardcoded price range for the category
		final priceRange = categoryPrices[category.toLowerCase()] ?? '₹1,000 - ₹3,000';
		print('DEBUG: Selected price range: $priceRange');
		
		return priceRange;
	}

	void _onUpload() {
		if (productName.trim().isEmpty || artworkDesc.trim().isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Please fill in required fields')),
			);
			return;
		}

		Navigator.push(
			context,
			MaterialPageRoute(
				builder: (context) => PrePostOverview(
					artisanName: widget.artisanName ?? 'Anonymous Artist',
					artisanCategory: widget.artisanCategory ?? 'Artisan',
					location: widget.location ?? 'India',
					productName: productName,
					productCategory: (editableCategory.isNotEmpty) ? editableCategory : 'Ceramic, Paint',
					productDescription: artworkDesc,
					previewImagePath: _image?.path ?? 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600',
					productPrice: predictedPrice,
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFF7F9FC),
			body: SafeArea(
				child: SingleChildScrollView(
					padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							// App bar with close and title
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									IconButton(
										icon: const Icon(Icons.close, size: 26),
										onPressed: () => Navigator.pop(context),
									),
									const Text(
										"Upload",
										style: TextStyle(
												fontWeight: FontWeight.bold,
												fontSize: 18,
												color: Color(0xFF0C141C)),
									),
									const SizedBox(width: 44),
								],
							),
							const SizedBox(height: 10),
							// Large product image or placeholder rounded
							GestureDetector(
								onTap: _pickImage,
								child: ClipRRect(
									borderRadius: BorderRadius.circular(16),
									child: _image != null
											? Image.file(
										_image!,
										height: 170,
										width: double.infinity,
										fit: BoxFit.cover,
									)
								: Image.network(
									'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80',
									height: 170,
									width: double.infinity,
									fit: BoxFit.cover,
									errorBuilder: (context, error, stack) {
										return Container(
											height: 170,
											width: double.infinity,
											color: const Color(0xFFE8EDF4),
											alignment: Alignment.center,
											child: const Icon(Icons.image_not_supported, color: Colors.grey),
										);
									},
								),
								),
							),
							const SizedBox(height: 20),
							// Product Name
							const Text(
								"Product Name",
								style: TextStyle(
										color: Color(0xFF0C141C),
										fontWeight: FontWeight.bold,
										fontSize: 15),
							),
							const SizedBox(height: 7),
							Container(
								decoration: BoxDecoration(
									color: const Color(0xFFE8EDF4),
									borderRadius: BorderRadius.circular(11),
								),
								child: TextField(
									onChanged: (val) => setState(() => productName = val),
									decoration: const InputDecoration(
										hintText: 'Enter product name',
										hintStyle: TextStyle(color: Color(0xFF97A1B2)),
										border: InputBorder.none,
										contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
									),
									style: const TextStyle(color: Color(0xFF49729B), fontSize: 16),
								),
							),
							const SizedBox(height: 18),
							// Describe your artwork
							const Text("Describe your artwork",
									style: TextStyle(
											fontWeight: FontWeight.bold,
											fontSize: 15,
											color: Color(0xFF0C141C))),
							const SizedBox(height: 7),
							Container(
								decoration: BoxDecoration(
									color: const Color(0xFFE8EDF4),
									borderRadius: BorderRadius.circular(11),
								),
								child: TextField(
									maxLines: 4,
									onChanged: (val) => setState(() => artworkDesc = val),
									decoration: const InputDecoration(
										hintText: "Describe your artwork",
										hintStyle: TextStyle(color: Color(0xFF97A1B2)),
										border: InputBorder.none,
										contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
									),
									style: const TextStyle(color: Color(0xFF49729B), fontSize: 16),
								),
							),
							const SizedBox(height: 12),
							// Voice Assistant: Icon above button
							Center(
								child: Column(
									children: [
										InkWell(
											onTap: _onVoiceAssistantTap,
											borderRadius: BorderRadius.circular(20),
											child: Container(
												width: 36,
												height: 36,
												decoration: BoxDecoration(
													color: const Color(0xFFE8EDF4),
													shape: BoxShape.circle,
												),
												child: const Icon(
													Icons.mic_none,
													color: Color(0xFF49729B),
													size: 22,
												),
											),
										),
										const SizedBox(height: 5),
										const Text(
											"Voice Assistant",
											style: TextStyle(
												color: Color(0xFF0C141C),
												fontWeight: FontWeight.w500,
												fontSize: 13,
											),
										),
									],
								),
							),
							const SizedBox(height: 24),
				// Category
							const Text(
								"Category",
								style: TextStyle(
									fontWeight: FontWeight.bold,
									fontSize: 15,
									color: Color(0xFF0C141C),
								),
							),
							const SizedBox(height: 7),
				Container(
					decoration: BoxDecoration(
						color: const Color(0xFFE8EDF4),
						borderRadius: BorderRadius.circular(11),
					),
					padding: const EdgeInsets.symmetric(horizontal: 8),
					child: Row(
						children: [
							Expanded(
								child: TextField(
									controller: _categoryController,
									onChanged: (val) => setState(() => editableCategory = val),
									decoration: const InputDecoration(
										hintText: 'Choose or type category',
										hintStyle: TextStyle(color: Color(0xFF97A1B2)),
										border: InputBorder.none,
									),
									style: const TextStyle(color: Color(0xFF49729B), fontSize: 16),
								),
							),
							IconButton(
								icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF49729B)),
								onPressed: _openCategorySheet,
							),
						],
					),
				),
							const SizedBox(height: 14),
							// AI Assistant note
							const Text(
								"Understanding your art's market value helps you appreciate the worth of your craftsmanship and time invested.",
								style: TextStyle(
									color: Color(0xFF444B58),
									fontSize: 14,
								),
							),
							const SizedBox(height: 16),
				// Market Value Range (muted rectangle)
							const Text(
								"Market Value Range",
								style: TextStyle(
										color: Color(0xFF0C141C),
										fontWeight: FontWeight.bold,
										fontSize: 15),
							),
							const SizedBox(height: 7),
				Container(
					decoration: BoxDecoration(
						color: const Color(0xFFE8EDF4),
						borderRadius: BorderRadius.circular(12),
					),
					alignment: Alignment.center,
					height: 48,
					width: double.infinity,
					padding: const EdgeInsets.symmetric(horizontal: 16),
					child: isPredictingPrice
						? const Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								SizedBox(
									width: 16,
									height: 16,
									child: CircularProgressIndicator(
										strokeWidth: 2,
										valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF49729B)),
									),
								),
								SizedBox(width: 8),
								Text(
									"Analyzing market trends...",
									style: TextStyle(
										color: Color(0xFF49729B),
										fontSize: 16,
										fontWeight: FontWeight.w500,
									),
								),
							],
						)
						: Text(
							"$predictedPriceLow - $predictedPriceHigh",
							style: const TextStyle(
								color: Color(0xFF49729B),
								fontSize: 18,
								fontWeight: FontWeight.w600,
							),
						),
				),
							const SizedBox(height: 18),
                const SizedBox(height: 28),
							// Upload button
							SizedBox(
								width: double.infinity,
								child: ElevatedButton(
									onPressed: _onUpload,
									style: ElevatedButton.styleFrom(
										elevation: 0,
										backgroundColor: const Color(0xFF3D99F4),
										shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(11)),
										padding: const EdgeInsets.symmetric(vertical: 16),
									),
									child: const Text(
										"Upload",
										style: TextStyle(
												color: Colors.white,
												fontWeight: FontWeight.w600,
												fontSize: 16),
									),
								),
							),
							const SizedBox(height: 16),
						],
					),
				),
			),
		);
	}
}