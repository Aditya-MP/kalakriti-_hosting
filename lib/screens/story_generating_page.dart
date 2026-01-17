import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StoryGeneratingPage extends StatefulWidget {
  const StoryGeneratingPage({super.key});

  @override
  State<StoryGeneratingPage> createState() => _StoryGeneratingPageState();
}

class _StoryGeneratingPageState extends State<StoryGeneratingPage> {
  // Core artisan theme
  final Color primaryEarth = const Color(0xFFE27D5F);
  final Color goldAccent = const Color(0xFFD4A574);
  final Color clayBg = const Color(0xFFF5F2E9);
  final Color deepHeritage = const Color(0xFF4A7043);

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isGenerating = false;
  String _recognizedText = '';
  String _generatedStory = '';
  final TextEditingController _storyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize();
    if (!available) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Speech not available')));
    }
  }

  Future<void> _startListening() async {
    if (await Permission.microphone.request() != PermissionStatus.granted) return;
    setState(() => _isListening = true);
    _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
          _storyController.text = _recognizedText;
        });
        if (result.finalResult) _stopListening();
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
    if (_recognizedText.isNotEmpty) _generateStory();
  }

  Future<void> _generateStory() async {
    setState(() => _isGenerating = true);
    
    try {
      // Try OpenAI GPT-3.5 Turbo (free tier available)
      final openaiResponse = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your-api-key', // Replace with actual key
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [{
            'role': 'user',
            'content': 'Transform this artisan speech into a compelling artwork story (100-200 words): $_recognizedText'
          }],
          'max_tokens': 300
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (openaiResponse.statusCode == 200) {
        final data = json.decode(openaiResponse.body);
        final story = data['choices']?[0]?['message']?['content'] ?? '';
        if (story.isNotEmpty) {
          setState(() => _generatedStory = story.trim());
          setState(() => _isGenerating = false);
          return;
        }
      }
    } catch (e) {
      print('OpenAI failed: $e');
    }
    
    try {
      // Try Hugging Face Inference API (free)
      final hfResponse = await http.post(
        Uri.parse('https://api-inference.huggingface.co/models/microsoft/DialoGPT-medium'),
        headers: {
          'Authorization': 'Bearer your-api-key', // Replace with HF token
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': 'Transform this artisan speech into a compelling artwork story: $_recognizedText',
          'parameters': {'max_length': 200}
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (hfResponse.statusCode == 200) {
        final data = json.decode(hfResponse.body);
        if (data is List && data.isNotEmpty) {
          final story = data[0]['generated_text'] ?? '';
          if (story.isNotEmpty) {
            setState(() => _generatedStory = story.trim());
            setState(() => _isGenerating = false);
            return;
          }
        }
      }
    } catch (e) {
      print('HuggingFace failed: $e');
    }
    
    try {
      // Try Cohere API (free tier)
      final cohereResponse = await http.post(
        Uri.parse('https://api.cohere.ai/v1/generate'),
        headers: {
          'Authorization': 'Bearer your-api-key', // Replace with Cohere key
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'command-light',
          'prompt': 'Transform this artisan speech into a compelling artwork story (100-200 words): $_recognizedText',
          'max_tokens': 200
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (cohereResponse.statusCode == 200) {
        final data = json.decode(cohereResponse.body);
        final story = data['generations']?[0]?['text'] ?? '';
        if (story.isNotEmpty) {
          setState(() => _generatedStory = story.trim());
          setState(() => _isGenerating = false);
          return;
        }
      }
    } catch (e) {
      print('Cohere failed: $e');
    }
    
    // Enhanced fallback with dynamic content
    setState(() => _generatedStory = _enhancedFallback(_recognizedText));
    setState(() => _isGenerating = false);
  }
  
  String _enhancedFallback(String speech) {
    final keywords = speech.toLowerCase().split(' ');
    String material = 'clay';
    String emotion = 'passion';
    String technique = 'traditional methods';
    
    if (keywords.any((w) => ['wood', 'carving', 'timber'].contains(w))) material = 'wood';
    if (keywords.any((w) => ['fabric', 'thread', 'weaving'].contains(w))) material = 'fabric';
    if (keywords.any((w) => ['metal', 'bronze', 'copper'].contains(w))) material = 'metal';
    
    if (keywords.any((w) => ['love', 'heart', 'soul'].contains(w))) emotion = 'deep love';
    if (keywords.any((w) => ['patience', 'time', 'slow'].contains(w))) emotion = 'patience';
    
    return 'In my workshop, where $material meets skilled hands, I pour $emotion into every creation. '
        'This piece tells the story of heritage passed down through generations, crafted using $technique '
        'that my ancestors perfected. Each curve, each detail speaks of countless hours spent in meditation '
        'with my craft. When you hold this artwork, you hold not just an object, but a piece of my soul, '
        'a fragment of our cultural legacy, and the whispered dreams of artisans who came before me.';
  }

  String _fallbackStory(String speech) {
    return 'In the heart of my workshop, where hands meet clay/wood/thread, I craft stories from raw materials. '
        'Each piece carries the rhythm of my journey, the colors of tradition, and whispers of innovation. '
        'This artwork emerged from passion and patience, shaped by years of mastering my craft.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clayBg,
      appBar: AppBar(
        title: const Text('Voice Artisan Story', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, 
        elevation: 0,
        foregroundColor: deepHeritage,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header with Artisan Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryEarth.withOpacity(0.1), goldAccent.withOpacity(0.1)]),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: goldAccent.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.record_voice_over, size: 64, color: primaryEarth),
                    const SizedBox(height: 12),
                    const Text("Speak Your Creation's Soul", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Voice → AI → Perfect Story", style: TextStyle(color: deepHeritage.withOpacity(0.7))),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Large Voice Button
              GestureDetector(
                onTap: _isListening || _isGenerating ? null : _startListening,
                child: Container(
                  width: 120, 
                  height: 120,
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.red : primaryEarth,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: primaryEarth.withOpacity(0.4), blurRadius: 30, spreadRadius: 2)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isListening ? Icons.stop : Icons.mic, size: 48, color: Colors.white),
                      const SizedBox(height: 8),
                      Text(_isListening ? "Listening..." : "Tap to Speak", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Recognized Speech Preview
              Text("Heard:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: deepHeritage)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border(left: BorderSide(width: 4, color: goldAccent)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Text(_recognizedText.isEmpty ? "Start speaking..." : _recognizedText, style: const TextStyle(height: 1.4)),
              ),
              const SizedBox(height: 24),
              // Generated Story
              if (_generatedStory.isNotEmpty) ...[
                Text("AI Crafted Story:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: deepHeritage)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.white, goldAccent.withOpacity(0.05)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: goldAccent.withOpacity(0.1), blurRadius: 15)],
                  ),
                  child: SingleChildScrollView(child: Text(_generatedStory, style: const TextStyle(height: 1.5))),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _storyController.text = _generatedStory;
                          Navigator.pop(context, _generatedStory);
                        },
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text("Use This Story"),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryEarth, foregroundColor: Colors.white),
                      )
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _recognizedText = '';
                            _generatedStory = '';
                          });
                        },
                        icon: const Icon(Icons.mic),
                        label: const Text("Try Again"),
                        style: OutlinedButton.styleFrom(foregroundColor: primaryEarth, side: BorderSide(color: primaryEarth)),
                      )
                    ),
                  ],
                ),
              ],
              const Spacer(),
              // Help Text
              Opacity(
                opacity: 0.6,
                child: Text("Speak clearly about your artwork's creation process", textAlign: TextAlign.center, style: TextStyle(color: deepHeritage)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

