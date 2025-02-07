import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/story.dart';
import 'models/comment.dart';

class ApiClient {
  static const _baseUrl = 'https://hacker-news.firebaseio.com/v0';
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<List<int>> getTopStories() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/topstories.json'),
    );

    if (response.statusCode == 200) {
      return List<int>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load top stories');
    }
  }

  Future<Story> getStory(int id) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/item/$id.json'),
    );

    if (response.statusCode == 200) {
      return Story.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load story');
    }
  }

  Future<List<Story>> getStories(List<int> ids, {int limit = 20}) async {
    final limitedIds = ids.take(limit).toList();
    final stories = await Future.wait(
      limitedIds.map((id) => getStory(id)),
    );
    return stories;
  }

  Future<Comment> getComment(int id) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/item/$id.json'),
    );

    if (response.statusCode == 200) {
      return Comment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load comment');
    }
  }

  Future<List<Comment>> getComments(List<int> ids) async {
    final comments = await Future.wait(
      ids.map((id) => getComment(id)),
    );
    return comments;
  }
}