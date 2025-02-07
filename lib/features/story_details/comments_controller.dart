import 'package:flutter/foundation.dart';
import '../../api/api_client.dart';
import '../../api/models/comment.dart';

class CommentsController extends ChangeNotifier {
  final ApiClient _apiClient;
  final List<int> commentIds;
  
  Map<int, Comment>? _comments;
  Set<int> _loadingComments = {};
  String? _error;
  bool _isLoading = false;

  CommentsController({
    required this.commentIds,
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient() {
    loadRootComments();
  }

  Map<int, Comment>? get comments => _comments;
  List<int> get rootCommentIds => commentIds;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool isCommentLoading(int id) => _loadingComments.contains(id);

  Future<void> loadRootComments() async {
    if (commentIds.isEmpty) return;

    _isLoading = true;
    _error = null;
    _comments = {};
    notifyListeners();

    try {
      final comments = await _apiClient.getComments(commentIds);
      for (final comment in comments) {
        _comments![comment.id] = comment;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReplies(int parentId) async {
    final parent = _comments?[parentId];
    if (parent == null || parent.kids.isEmpty || _loadingComments.contains(parentId)) return;

    _loadingComments.add(parentId);
    notifyListeners();

    try {
      final replies = await _apiClient.getComments(parent.kids);
      for (final reply in replies) {
        _comments![reply.id] = reply;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingComments.remove(parentId);
      notifyListeners();
    }
  }
}