import 'package:flutter/foundation.dart';
import '../../api/api_client.dart';
import 'stories_state.dart';

class StoriesController extends ChangeNotifier {
  final ApiClient _apiClient;
  StoriesState _state = StoriesState(isLoading: true);

  StoriesController({ApiClient? apiClient}) 
      : _apiClient = apiClient ?? ApiClient() {
    loadStories();
  }

  StoriesState get state => _state;

  Future<void> loadStories() async {
    _state = StoriesState(isLoading: true);
    notifyListeners();

    try {
      final ids = await _apiClient.getTopStories();
      final stories = await _apiClient.getStories(ids);
      _state = StoriesState(stories: stories);
    } catch (e) {
      _state = StoriesState(error: e.toString());
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }
}