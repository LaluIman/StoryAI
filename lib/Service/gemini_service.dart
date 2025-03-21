import 'dart:convert';
import 'dart:developer';

import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String apiKey = "AIzaSyCoGeLR5jkYFBNphZXmadQCY5JkYHJQ9kI";

  static Future<Map<String, dynamic>> generateStory(
      Map<String, dynamic> storyIdea) async {
    final prompt = _buildPrompt(storyIdea);

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.9,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
    );

    final chat = model.startChat(history: [
      Content.multi([
        TextPart(
            'You are a creative bedtime story writer for children. Create engaging, age-appropriate stories with positive themes, clear morals, and charming characters. Stories should be calming and suitable for bedtime. Include a title, main story, brief summary, and moral lessons. Provide output in JSON format with "title", "content", "summary", and "morals" (as an array) fields. Use emoji where appropriate. Do not include any additional text outside the JSON structure.')
      ]),
    ]);

    final content = Content.text(prompt);

    try {
      final response = await chat.sendMessage(content);
      final responseText =
          (response.candidates.first.content.parts.first as TextPart).text;

      if (responseText.isEmpty) {
        return {'error': 'No response from Gemini'};
      }

      RegExp jsonPattern = RegExp(r'\{.*\}', dotAll: true);
      Match? match = jsonPattern.firstMatch(responseText);

      if (match != null) {
        return json.decode(match.group(0)!);
      }

      return json.decode(responseText);
    } catch (e) {
      log('Error generating story: $e');
      return {'error': 'Failed to generate story\n$e'};
    }
  }

  static String _buildPrompt(Map<String, dynamic> storyIdea) {
    String idea = storyIdea['idea'] ?? '';
    String characters = storyIdea['characters'] ?? '';
    String theme = storyIdea['theme'] ?? 'Adventure';

    String prompt = "Create a bedtime story with the following elements:\n";
    prompt += "- Main idea: $idea\n";
    
    if (characters.isNotEmpty) {
      prompt += "- Main characters: $characters\n";
    }
    
    prompt += "- Theme: $theme\n";
    prompt += "Please make the story engaging, age-appropriate, and with a clear moral lesson. Include a title, the main story content, a brief summary, and moral lessons. Return the response in JSON format.";

    return prompt;
  }
}