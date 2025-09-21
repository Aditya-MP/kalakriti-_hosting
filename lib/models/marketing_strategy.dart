class MarketingStrategy {
  final List<String> contentIdeas;
  final List<String> hashtags;
  final String postingTimes;
  final List<String> pricingStrategies;
  final List<String> engagementTactics;
  final String rawResponse; // Store the full AI response for debugging
  
  MarketingStrategy({
    required this.contentIdeas,
    required this.hashtags,
    required this.postingTimes,
    required this.pricingStrategies,
    required this.engagementTactics,
    required this.rawResponse,
  });
  
  // Factory constructor for creating from AI response
  factory MarketingStrategy.fromAIResponse(String response) {
    return MarketingStrategy(
      contentIdeas: _extractContentIdeas(response),
      hashtags: _extractHashtags(response),
      postingTimes: _extractPostingTimes(response),
      pricingStrategies: _extractPricingStrategies(response),
      engagementTactics: _extractEngagementTactics(response),
      rawResponse: response,
    );
  }
  
  // Extract content ideas from AI response
  static List<String> _extractContentIdeas(String response) {
    final List<String> ideas = [];
    final lines = response.split('\n');
    bool inContentSection = false;
    
    for (String line in lines) {
      line = line.trim();
      if (line.toLowerCase().contains('content ideas') || 
          line.toLowerCase().contains('content suggestions')) {
        inContentSection = true;
        continue;
      }
      if (inContentSection && line.startsWith('•')) {
        ideas.add(line.substring(1).trim());
      }
      if (inContentSection && (line.toLowerCase().contains('hashtags') || 
          line.toLowerCase().contains('posting times') ||
          line.toLowerCase().contains('pricing'))) {
        break;
      }
    }
    
    // If no structured content found, extract any bullet points
    if (ideas.isEmpty) {
      for (String line in lines) {
        if (line.trim().startsWith('•') || line.trim().startsWith('-')) {
          ideas.add(line.replaceAll(RegExp(r'^[•\-]\s*'), '').trim());
        }
      }
    }
    
    return ideas.take(5).toList(); // Limit to 5 ideas
  }
  
  // Extract hashtags from AI response
  static List<String> _extractHashtags(String response) {
    final List<String> hashtags = [];
    final hashtagRegex = RegExp(r'#\w+');
    final matches = hashtagRegex.allMatches(response);
    
    for (Match match in matches) {
      hashtags.add(match.group(0)!);
    }
    
    return hashtags.take(10).toList(); // Limit to 10 hashtags
  }
  
  // Extract posting times from AI response
  static String _extractPostingTimes(String response) {
    final lines = response.split('\n');
    for (String line in lines) {
      if (line.toLowerCase().contains('posting times') || 
          line.toLowerCase().contains('best times')) {
        // Look for time patterns in the next few lines
        for (int i = 0; i < 3; i++) {
          final nextLine = lines[lines.indexOf(line) + i + 1];
          if (nextLine.contains(RegExp(r'\d+:\d+|\d+\s*[ap]m'))) {
            return nextLine.trim();
          }
        }
      }
    }
    
    // Fallback to common times
    return '7-9 AM, 6-8 PM';
  }
  
  // Extract pricing strategies from AI response
  static List<String> _extractPricingStrategies(String response) {
    final List<String> strategies = [];
    final lines = response.split('\n');
    bool inPricingSection = false;
    
    for (String line in lines) {
      line = line.trim();
      if (line.toLowerCase().contains('pricing') || 
          line.toLowerCase().contains('price')) {
        inPricingSection = true;
        continue;
      }
      if (inPricingSection && (line.startsWith('•') || line.startsWith('-'))) {
        strategies.add(line.substring(1).trim());
      }
      if (inPricingSection && (line.toLowerCase().contains('engagement') || 
          line.toLowerCase().contains('tactics'))) {
        break;
      }
    }
    
    // If no structured pricing found, add common strategies
    if (strategies.isEmpty) {
      strategies.addAll([
        'Show value: "3 days of skilled work"',
        'Bundle deals: "Buy 2, get 1 free"',
        'Limited editions: "Only 5 pieces made"',
      ]);
    }
    
    return strategies.take(3).toList();
  }
  
  // Extract engagement tactics from AI response
  static List<String> _extractEngagementTactics(String response) {
    final List<String> tactics = [];
    final lines = response.split('\n');
    bool inEngagementSection = false;
    
    for (String line in lines) {
      line = line.trim();
      if (line.toLowerCase().contains('engagement') || 
          line.toLowerCase().contains('tactics')) {
        inEngagementSection = true;
        continue;
      }
      if (inEngagementSection && (line.startsWith('•') || line.startsWith('-'))) {
        tactics.add(line.substring(1).trim());
      }
    }
    
    // If no structured engagement found, add common tactics
    if (tactics.isEmpty) {
      tactics.addAll([
        'Ask questions in captions',
        'Share customer reviews',
        'Post behind-the-scenes content',
      ]);
    }
    
    return tactics.take(3).toList();
  }
}
