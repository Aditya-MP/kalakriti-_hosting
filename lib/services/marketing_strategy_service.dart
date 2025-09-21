import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/marketing_strategy.dart';

class MarketingStrategyService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static List<String> get _endpoints => [
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$_apiKey',
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$_apiKey',
  ];
  
  static Future<MarketingStrategy> generateStrategy({
    required String productName,
    required String productCategory,
    required String productDescription,
    required String socialMediaPlatform,
  }) async {
    print('🎯 Generating marketing strategy for: $productName on $socialMediaPlatform');
    
    // Try multiple API endpoints
    for (String endpoint in _endpoints) {
      try {
        print('🔄 Trying endpoint: $endpoint');
        
        final prompt = _buildPrompt(productName, productCategory, productDescription, socialMediaPlatform);
        print('📝 Prompt: $prompt');
        
        final response = await http.post(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'contents': [{
              'parts': [{
                'text': prompt
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

        print('📊 API Response Status: ${response.statusCode}');
        print('📄 API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('🔍 Parsed data: $data');
          
          if (data['candidates'] != null && data['candidates'].isNotEmpty) {
            final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
            print('✅ SUCCESS: Generated marketing strategy');
            print('📋 Strategy: $generatedText');
            
            final strategy = MarketingStrategy.fromAIResponse(generatedText);
            print('🎯 Parsed strategy: ${strategy.contentIdeas.length} content ideas, ${strategy.hashtags.length} hashtags');
            return strategy;
          } else {
            print('❌ No candidates in response');
          }
        } else {
          print('❌ API error with endpoint $endpoint: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('❌ API call failed with endpoint $endpoint: $e');
      }
    }
    
    // If all endpoints fail, return a fallback strategy
    print('⚠️ All API endpoints failed, using fallback strategy');
    return _getFallbackStrategy(productName, productCategory, socialMediaPlatform);
  }
  
  static String _buildPrompt(String productName, String productCategory, String productDescription, String socialMediaPlatform) {
    return '''
You are a marketing expert specializing in handmade crafts and artisan products. Generate a unique, platform-specific marketing strategy for this product:

PRODUCT DETAILS:
- Name: $productName
- Category: $productCategory  
- Description: $productDescription
- Target Platform: $socialMediaPlatform

PLATFORM CONTEXT:
- Gaatha: Storytelling-based craft platform focusing on artisan narratives
- Flipkart Samarth: E-commerce platform for handicrafts with professional selling
- Pinterest: Visual discovery platform for inspiration and craft ideas
- Instagram: Visual storytelling with reels and stories for crafts
- Facebook: Community platform for craft groups and pages

REQUIREMENTS:
1. Make this strategy UNIQUE and SPECIFIC to this exact product
2. Consider the current market trends and season
3. Provide actionable, implementable advice
4. Use the platform's unique features effectively

FORMAT YOUR RESPONSE EXACTLY AS:

📸 CONTENT IDEAS:
• [5 unique content ideas specifically for $socialMediaPlatform and this $productCategory]

 HASHTAGS:
[10 trending hashtags for $productCategory on $socialMediaPlatform - include platform-specific tags]

⏰ BEST POSTING TIMES:
[Specific optimal times for $socialMediaPlatform based on current user behavior]

💰 PRICING STRATEGIES:
• [3 creative pricing strategies for this specific $productCategory on $socialMediaPlatform]

🎯 ENGAGEMENT TACTICS:
• [3 specific engagement tactics for $socialMediaPlatform and $productCategory]

Make each suggestion unique, current, and tailored to this specific product and platform combination.

CURRENT TIMESTAMP: ${DateTime.now().millisecondsSinceEpoch}
RANDOM SEED: ${DateTime.now().microsecond}
''';
  }
  
  static MarketingStrategy _getFallbackStrategy(String productName, String productCategory, String socialMediaPlatform) {
    // Create category-specific fallback strategies
    final Map<String, Map<String, dynamic>> fallbackStrategies = {
      'pottery': {
        'contentIdeas': [
          'Behind-the-scenes videos of pottery making',
          'Before/after shots: clay to finished product',
          'Customer testimonials with your pottery',
          'Seasonal collections (Diwali, wedding season)',
          'Workshop demonstrations and techniques'
        ],
        'hashtags': ['#HandmadePottery', '#JaipurPottery', '#IndianCraft', '#PotteryArt', '#ClayArt', '#ArtisanMade', '#LocalCraft', '#SustainableLiving', '#Handcrafted', '#PotteryLove'],
        'postingTimes': '7-9 AM, 6-8 PM',
        'pricingStrategies': [
          'Show value: "3 days of skilled work"',
          'Bundle deals: "Buy 2, get 1 free"',
          'Limited editions: "Only 5 pieces made"'
        ],
        'engagementTactics': [
          'Ask questions in captions',
          'Share customer reviews',
          'Post behind-the-scenes content'
        ]
      },
      'jewelry': {
        'contentIdeas': [
          'Close-up shots of intricate details',
          'Jewelry on different skin tones',
          'Before/after: raw stones to finished pieces',
          'Customer wearing jewelry at events',
          'Jewelry care tips and maintenance'
        ],
        'hashtags': ['#HandmadeJewelry', '#IndianJewelry', '#ArtisanMade', '#JewelryDesign', '#SustainableFashion', '#LocalCraft', '#JewelryLover', '#Handcrafted', '#JewelryArt', '#FashionAccessories'],
        'postingTimes': '9-11 AM, 7-9 PM',
        'pricingStrategies': [
          'Show material costs: "Real silver + 2 days of work"',
          'Bundle deals: "Earrings + Necklace set"',
          'Limited editions: "Only 5 pieces made"'
        ],
        'engagementTactics': [
          'Ask "Which design do you prefer? A or B?"',
          'Share customer styling photos',
          'Post jewelry care tips'
        ]
      },
      'textiles': {
        'contentIdeas': [
          'Weaving process videos',
          'Fabric texture close-ups',
          'Customer wearing your textiles',
          'Seasonal color collections',
          'Traditional technique demonstrations'
        ],
        'hashtags': ['#Handwoven', '#IndianTextiles', '#ArtisanMade', '#SustainableFashion', '#LocalCraft', '#Handcrafted', '#TextileArt', '#Weaving', '#FabricLove', '#TraditionalCraft'],
        'postingTimes': '8-10 AM, 6-8 PM',
        'pricingStrategies': [
          'Show weaving time: "2 weeks of hand weaving"',
          'Seasonal collections: "Festival special rates"',
          'Custom orders: "Made to your measurements"'
        ],
        'engagementTactics': [
          'Show fabric care instructions',
          'Share customer styling tips',
          'Post weaving technique videos'
        ]
      }
    };
    
    // Get strategy for the category or use default
    final categoryKey = productCategory.toLowerCase();
    final strategy = fallbackStrategies[categoryKey] ?? fallbackStrategies['pottery']!;
    
    // Modify content ideas based on platform
    List<String> platformSpecificIdeas = _getPlatformSpecificContentIdeas(
      List<String>.from(strategy['contentIdeas']), 
      socialMediaPlatform
    );
    
    return MarketingStrategy(
      contentIdeas: platformSpecificIdeas,
      hashtags: List<String>.from(strategy['hashtags']),
      postingTimes: _getPlatformSpecificPostingTimes(socialMediaPlatform),
      pricingStrategies: List<String>.from(strategy['pricingStrategies']),
      engagementTactics: _getPlatformSpecificEngagementTactics(socialMediaPlatform),
      rawResponse: 'Fallback strategy for $productCategory on $socialMediaPlatform',
    );
  }
  
  static List<String> _getPlatformSpecificContentIdeas(List<String> baseIdeas, String platform) {
    switch (platform.toLowerCase()) {
      case 'gaatha':
        return [
          'Craft stories and artisan journey narratives',
          'Traditional technique documentation with cultural context',
          'Behind-the-scenes videos of craft creation process',
          'Artisan interviews and personal stories',
          'Cultural significance and heritage of your craft'
        ];
      case 'flipkart samarth':
        return [
          'Professional product photos with detailed descriptions',
          'Customer reviews and testimonials',
          'Craft quality and authenticity highlights',
          'Shipping and packaging showcase',
          'Bulk order and wholesale information'
        ];
      case 'pinterest':
        return [
          'High-quality craft photos with lifestyle context',
          'Step-by-step process infographics',
          'Inspiration boards and mood boards',
          'DIY tutorials and craft guides',
          'Seasonal and themed craft collections'
        ];
      case 'instagram':
        return [
          'Behind-the-scenes Stories and Reels of craft making',
          'High-quality product photos with natural lighting',
          'Before/after transformation posts',
          'Customer testimonials with craft photos',
          'Workshop process videos and tutorials'
        ];
      case 'facebook':
        return [
          'Detailed craft descriptions with multiple photos',
          'Customer reviews and testimonials',
          'Live video demonstrations of craft techniques',
          'Community engagement posts and craft discussions',
          'Event announcements and workshop details'
        ];
      default:
        return baseIdeas;
    }
  }
  
  static String _getPlatformSpecificPostingTimes(String platform) {
    switch (platform.toLowerCase()) {
      case 'gaatha':
        return '10 AM-12 PM, 6-8 PM (Storytelling time)';
      case 'flipkart samarth':
        return '9-11 AM, 2-4 PM, 7-9 PM (Shopping hours)';
      case 'pinterest':
        return '8-11 PM, 2-4 AM (Inspiration browsing)';
      case 'instagram':
        return '7-9 AM, 12-2 PM, 6-8 PM (Visual content)';
      case 'facebook':
        return '9-11 AM, 1-3 PM, 7-9 PM (Community engagement)';
      default:
        return '7-9 AM, 6-8 PM';
    }
  }
  
  static List<String> _getPlatformSpecificEngagementTactics(String platform) {
    switch (platform.toLowerCase()) {
      case 'gaatha':
        return [
          'Share artisan stories and cultural heritage',
          'Engage with craft community discussions',
          'Participate in storytelling challenges'
        ];
      case 'flipkart samarth':
        return [
          'Highlight craft authenticity and quality',
          'Share customer testimonials and reviews',
          'Provide detailed product information'
        ];
      case 'pinterest':
        return [
          'Create themed boards for different craft seasons',
          'Pin high-quality lifestyle craft images',
          'Use rich pins for detailed craft information'
        ];
      case 'instagram':
        return [
          'Use Stories polls and questions about crafts',
          'Respond to comments within 2 hours',
          'Share user-generated craft content'
        ];
      case 'facebook':
        return [
          'Ask questions about craft techniques',
          'Share customer reviews and craft photos',
          'Create Facebook events for craft workshops'
        ];
      default:
        return [
          'Ask questions in captions',
          'Share customer reviews',
          'Post behind-the-scenes content'
        ];
    }
  }
}
