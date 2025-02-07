import 'package:flutter/material.dart';
import '../../api/models/comment.dart';
import '../../api/models/story.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/ai_service.dart';
import '../../core/widgets/ai_comment_card.dart';
import '../../core/widgets/roast_button.dart';
import 'comments_controller.dart';
import 'comment_card.dart';
import '../../core/utils/text_utils.dart';

class StoryDetailsPage extends StatefulWidget {
  final Story story;

  const StoryDetailsPage({
    super.key,
    required this.story,
  });

  @override
  State<StoryDetailsPage> createState() => _StoryDetailsPageState();
}

class _StoryDetailsPageState extends State<StoryDetailsPage> {
  late final CommentsController _commentsController;
  final _aiService = AiService();
  String? _roastComment;
  bool _isLoadingRoast = false;

  Future<void> _loadRoast() async {
    setState(() {
      _isLoadingRoast = true;
    });

    try {
      final comment = await _aiService.getCommentaryForStory(
        widget.story.title,
        widget.story.text,
        widget.story.url,
      );
      setState(() {
        _roastComment = comment;
      });
    } catch (e) {
      setState(() {
        _roastComment = 'Failed to generate AI commentary: $e';
      });
    } finally {
      setState(() {
        _isLoadingRoast = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _commentsController = CommentsController(commentIds: widget.story.kids);
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Widget _buildComments() {
    return ListenableBuilder(
      listenable: _commentsController,
      builder: (context, _) {
        if (_commentsController.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (_commentsController.error != null) {
          return Center(
            child: Text(_commentsController.error!),
          );
        }

        final comments = _commentsController.comments;
        if (comments == null || comments.isEmpty) {
          return const Center(
            child: Text('No comments yet'),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _commentsController.rootCommentIds.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final rootId = _commentsController.rootCommentIds[index];
            final rootComment = comments[rootId];
            if (rootComment == null) return const SizedBox.shrink();
            return _buildCommentTree(rootComment, comments);
          },
        );
      },
    );
  }

  Widget _buildCommentTree(Comment comment, Map<int, Comment> allComments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentCard(
          comment: comment,
          isLoadingReplies: _commentsController.isCommentLoading(comment.id),
          onLoadReplies: () => _commentsController.loadReplies(comment.id),
          showReplies: comment.kids.any((kidId) => allComments.containsKey(kidId)),
        ),
        if (comment.kids.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: comment.kids.map((kidId) {
                final kidComment = allComments[kidId];
                if (kidComment == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildCommentTree(kidComment, allComments),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _formatTimeAgo(widget.story.dateTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    widget.story.by[0].toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.story.by,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.story.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.story.url != null) ...[
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => _launchUrl(widget.story.url!),
                icon: const Icon(Icons.link),
                label: Text(widget.story.domain),
              ),
            ],
            if (widget.story.text != null && widget.story.text!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEF8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  cleanHtmlText(widget.story.text!),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
            const SizedBox(height: 16),
            // После статистики
            Row(
              children: [
                _StatsChip(
                  icon: Icons.arrow_upward,
                  label: '${widget.story.score}',
                ),
                const SizedBox(width: 16),
                _StatsChip(
                  icon: Icons.comment_outlined,
                  label: '${widget.story.descendants}',
                ),
                const Spacer(),
                RoastButton(
                  isLoading: _isLoadingRoast,
                  onPressed: _loadRoast,
                ),
              ],
            ),
            if (_roastComment != null) ...[
              const SizedBox(height: 16),
              AiCommentCard(comment: _roastComment!),
            ],
            if (widget.story.descendants > 0) ...[
              const SizedBox(height: 24),
              Text(
                'Comments',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildComments(),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}

class _StatsChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatsChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}

Future<void> _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }
}