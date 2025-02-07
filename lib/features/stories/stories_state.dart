import '../../api/models/story.dart';

class StoriesState {
  final List<Story>? stories;
  final String? error;
  final bool isLoading;

  StoriesState({
    this.stories,
    this.error,
    this.isLoading = false,
  });

  StoriesState copyWith({
    List<Story>? stories,
    String? error,
    bool? isLoading,
  }) {
    return StoriesState(
      stories: stories ?? this.stories,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}