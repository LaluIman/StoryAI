import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_generator/models/story_model.dart';

class StorageService {
  static const String _key = 'saved_stories';

  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // nyimpan
  static Future<void> saveStory(Story story) async {
    final stories = await getStories();
    stories.add(story);
    await _saveStories(stories);
  }

  // ngambil cerita
  static Future<List<Story>> getStories() async {
    final prefs = await _getPrefs();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.map((item) => Story.fromJson(jsonDecode(item))).toList();
  }

  // hapus
  static Future<void> deleteStory(int index) async {
    final stories = await getStories();
    stories.removeAt(index);
    await _saveStories(stories);
  }

  // convert jadi list
  static Future<void> _saveStories(List<Story> stories) async {
    final prefs = await _getPrefs();
    final jsonList = stories.map((story) => jsonEncode(story.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }
}